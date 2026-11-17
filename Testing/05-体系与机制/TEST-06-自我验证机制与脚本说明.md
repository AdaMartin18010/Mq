# T.06 自我验证机制与脚本说明

> **本文档定位**：项目"可自我测试、验证、更新、修正"的机制说明——两个自检脚本（doc-self-check.sh、mq-smoke-test.sh）的用法、输出解读、CI/定时集成与处置流程。脚本本体在 `topics/scripts/`。

## 目录

- [T.06 自我验证机制与脚本说明](#t06-自我验证机制与脚本说明)
  - [目录](#目录)
  - [T.06.1 机制总览](#t061-机制总览)
  - [T.06.2 doc-self-check.sh：知识库规范自检](#t062-doc-self-checksh知识库规范自检)
  - [T.06.3 mq-smoke-test.sh：运行环境冒烟](#t063-mq-smoke-testsh运行环境冒烟)
  - [T.06.4 CI 与定时集成](#t064-ci-与定时集成)
  - [T.06.5 报告与处置流程](#t065-报告与处置流程)
  - [T.06.6 与治理批次的联动](#t066-与治理批次的联动)
  - [T.06.7 检查清单](#t067-检查清单)
  - [T.06.8 季度保鲜例行清单（知识库保鲜一页纸）](#t068-季度保鲜例行清单知识库保鲜一页纸)

---

## T.06.1 机制总览

自我验证覆盖两条线：

```text
知识库线（文档质量，每次变更/批次必跑）
  doc-self-check.sh quick|full|--skill-drift
    ├─ 结构检查：定位声明/最后更新/目录存在性
    ├─ 一致性检查：INDEX 登记/相对链接可达/统计数字对账
    ├─ 红线检查：禁用表述/归档文档引用/敏感信息
    └─ full 追加：密度抽样/技能漂移对账

运行环境线（系统可用性，有 Docker 才执行）
  mq-smoke-test.sh kafka|nats|rabbitmq|redis|mqtt|pulsar|all
    └─ 起容器 → 生产消费往返验证 → 清理（trap 保证）
```

两线互补：知识库线防"文档说谎"，运行环境线防"环境坏了不知道"。无 Docker 时运行环境线整体 SKIP（退出码 0 并说明），不阻塞批次。

## T.06.2 doc-self-check.sh：知识库规范自检

| 检查项 | 级别 | 说明 |
| -------- | ------ | ------ |
| 禁用表述扫描 | ERROR | "100% 完成""生产就绪"等违反 AGENTS.md §5 诚实口径的表述 |
| 归档文档引用 | ERROR | 对已归档 8 个完成度报告的文件名级引用（如 `COMPLETION_REPORT*.md`） |
| 相对链接可达 | ERROR | 文档内 `](...)` 相对链接目标不存在（外部 http 跳过） |
| 定位声明 | ERROR | 02/03 系列文档缺"本文档定位"（AGENTS.md §2 硬性分工） |
| 代码块语言标注 | WARN | 开 fence 无语言标注（``` 后应为 bash/java/...） |
| 最后更新日期 | WARN | 主题文档缺 `**最后更新**: YYYY-MM-DD` 或日期晚于今天 |
| INDEX 登记 | WARN | 01~04 系列文档未在 INDEX.md 登记 |
| 密度抽样 | WARN | full 模式：主题文档 < 80 行判骨架风险 |
| 统计对账 | WARN | 实地计数与 PROJECT_STATUS 声明不一致 |
| 技能漂移 | WARN | --skill-drift：AI_Skills/skills/ 源文档 mtime 晚于 derived-at |

```bash
# 用法（在项目根执行）
./topics/scripts/doc-self-check.sh quick            # 结构+红线（分钟级）
./topics/scripts/doc-self-check.sh full             # +密度+对账（批次收尾前）
./topics/scripts/doc-self-check.sh --skill-drift    # 技能对账（AI_Skill 配套）
echo $?   # 0=无 ERROR；1=存在 ERROR（WARN 不置失败位）
```

输出样例（2026-11-17 full 实录节选）：

```text
=== 知识库规范自检 (full) 2026-11-17 ===
--- 实地计数: 01=32 02=48 03=63 04=6 AI_Skill=6 Testing=7 examples=52 config=58 scripts=109
[WARN]  代码块缺语言标注: topics/03-架构与运维实践/03-09-集群管理与分布式架构.md:270
...
ERROR=0 WARN=150
✅ 自检通过
```

输出约定：`[ERROR]` 必须本批次修复；`[WARN]` 可挂账但须登记到批次报告。WARN 挂账的登记格式（批次报告固定一节）：

```text
## WARN 挂账清单（doc-self-check full）
- [ ] 代码块语言标注 ~120 处（存量 03/04 系列为主）——清偿计划：每批次顺手修 20 处
- [ ] 缺最后更新 23 篇（存量 01/02/04 系列）——清偿计划：触及即修
```

## T.06.3 mq-smoke-test.sh：运行环境冒烟

对六大系统做"起容器 → 收发往返 → 清理"的最小闭环（对应 TEST-02 的 TC-DEP-01~04 精简版）：

| 参数 | 环境来源 | 验证动作 |
| ------ | ---------- | ---------- |
| kafka | docker-compose-kafka.yml | kafka-topics 建删 + 控制台收发 |
| nats | docker-compose-nats.yml | JetStream 建流 + pub/sub 往返 |
| rabbitmq | docker-compose-rabbitmq.yml | 队列声明 + perf-test 10s |
| redis | `docker run redis:7-alpine` | XADD/XREAD 往返 |
| mqtt | `docker run eclipse-mosquitto` | mosquitto_pub/sub 往返 |
| pulsar | 无模板 | SKIP（提示按 TEST-02 手工环境） |
| all | 前四项依次 | 汇总报告 |

```bash
./topics/scripts/mq-smoke-test.sh kafka
# 典型输出：
# === Kafka 冒烟测试 ===
# [1/4] 启动容器...  ok
# [2/4] 等待就绪...  ok
# [3/4] 生产消费往返...  ok (1/1 条)
# [4/4] 清理...  ok
# ✅ PASS kafka
```

安全设计：清理用 `trap` 保证异常退出也执行 `compose down -v` / `docker rm -f`；端口被占时先探测并跳过；超时（默认 300s）自动清理。

## T.06.4 CI 与定时集成

```bash
# 1) Git pre-push 钩子（知识库线 quick）
cat > .git/hooks/pre-push <<'EOF'
#!/bin/bash
./topics/scripts/doc-self-check.sh quick || { echo "推送被拦：先修复 ERROR"; exit 1; }
EOF
chmod +x .git/hooks/pre-push

# 2) CI pipeline（发布门禁，对应 TEST-01 T.01.5）
./topics/scripts/doc-self-check.sh full
./topics/scripts/mq-smoke-test.sh all

# 3) 本地定时对账（Git Bash/cron 每日）
#    输出追加到 testing/self-check-history.log 供趋势观察
```

CI 完整流水线示例（GitHub Actions 风格伪代码）：

```yaml
# .github/workflows/verify.yml（示意，按需落地）
on: [push, pull_request]
jobs:
  doc-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash topics/scripts/doc-self-check.sh full
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash topics/scripts/mq-smoke-test.sh all   # 无 docker 时自动 SKIP
```

## T.06.5 报告与处置流程

1. 脚本输出即报告原文，批次说明中粘贴摘要（ERROR 0 行即可声明自检通过）。
2. ERROR 处置：当场修复或开单（挂 TEST-05 SLA）。
3. WARN 处置：登记批次报告"挂账清单"，下一批次优先清偿。
4. 误报处置：修改脚本白名单并在脚本注释写明理由（禁止静默忽略）。

处置流程的文字版闭环：

```text
doc-self-check 输出
  ├─ ERROR=0 → 批次可收尾（WARN 挂账清单附报告）
  └─ ERROR>0 → 逐条修复 → 复跑至 0 → 若为脚本误报 → 白名单+注释 → 复跑
mq-smoke-test 输出
  ├─ FAIL=0  → 环境健康结论入报告
  └─ FAIL>0  → 按 TEST-05 分类（多为 E 类）→ 环境修复后重跑
```

历史趋势观察：将每次 full 输出的 `ERROR=/WARN=` 行追加到 `Testing/self-check-history.log`；趋势规则——WARN 连续两月上升即触发专项治理批次（通常是新文档未遵守规范的征兆，先查最近批次的新增文件）。

## T.06.6 与治理批次的联动

- **批次收尾四件套之后**必须跑 `doc-self-check.sh full` 并全绿，方可向用户报批次完成（AGENTS.md §7.2.4 验收的自动化部分）。
- `--skill-drift` 结果喂给 AI_SKILL-02 AIS.02.5 的对账机制。
- 本机制自身也是被测对象：对脚本自身的修改须回放在 12 个已知文件集上（至少无新增误报）。

## T.06.7 检查清单

- [ ] quick 模式 ERROR=0 才允许批次报完成
- [ ] full 模式在 CHANGELOG 发版前执行并留档
- [ ] mq-smoke-test.sh 在有 Docker 的发布日执行 all
- [ ] WARN 挂账清单非空时批次报告须列出
- [ ] 脚本修改已回放验证无新增误报
- [ ] self-check-history.log 已追加本次 ERROR/WARN 计数值

## T.06.8 季度保鲜例行清单（知识库保鲜一页纸）

每季度最后一个工作日执行（约半天），四项例行：

| # | 例行项 | 执行方式 | 产出 |
| --- | -------- | ---------- | ------ |
| 1 | 版本基线复核 | 按 ROADMAP 版本追踪清单来源逐系统查新发布；出现大版本 GA（Kafka/Pulsar 等）30 天内更新专章 | 基线表更新或"无变化"记录 |
| 2 | 全量自检 + 外链巡检 | `doc-self-check.sh full`（含 300 上限外链 404 检查） | ERROR=0；外链失效修复清单 |
| 3 | 技能对账 | `--skill-drift`；触发重派生的技能更新 derived-at/last-verified | 对账记录 |
| 4 | 内容健康度抽样 | 抽 5 篇高频文档核对：时效声明未过期、置信标注与正文一致、命令可执行 | 抽样报告；发现的问题入批次18 或单独立项 |

执行纪律：例行结果四行式记录于 CHANGELOG 对应季度条目（"季度保鲜：基线✅ 自检 ERROR=0 外链修复 n 处 技能对账 m 项 抽样通过"）；发现系统性问题时升级为独立批次而非顺手大改。

---

**最后更新**: 2026-11-17
