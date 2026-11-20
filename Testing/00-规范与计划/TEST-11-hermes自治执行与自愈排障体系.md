# T.11 hermes 自治执行与自愈排障体系

> **置信口径**: 协议/规范语义=【定理】；架构对比与工程推理=【论证】；正文未单独标注的具体数字（阈值/百分比/时长）按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于 Podman/Docker/kind 官方文档与项目现有脚本实现核实至 2026-11。
> **本文档定位**: 定义本地执行者 hermes 的自治执行、分级自愈、失败排障 runbook 与自我修正闭环。不替代 TEST-05 的归因治理与 TEST-09 的环境矩阵，而是给出"机器能做什么、必须人在回路做什么"的操作边界。

## 目录

- [T.11 hermes 自治执行与自愈排障体系](#t11-hermes-自治执行与自愈排障体系)
  - [目录](#目录)
  - [T.11.1 自治执行闭环](#t111-自治执行闭环)
  - [T.11.2 自愈授权分级 L0-L3](#t112-自愈授权分级-l0-l3)
  - [T.11.3 排障排错 runbook](#t113-排障排错-runbook)
  - [T.11.4 自我更新/修正流程](#t114-自我更新修正流程)
  - [T.11.5 执行栈失败收集与日志归档](#t115-执行栈失败收集与日志归档)
  - [T.11.6 与现有文档的衔接](#t116-与现有文档的衔接)
  - [T.11.7 参考来源](#t117-参考来源)

---

## T.11.1 自治执行闭环

hermes 作为项目本地测试执行代理，其自治闭环由五个环节构成：

```text
验证(Verify) → 诊断(Diagnose) → 修复(Fix) → 自愈(Heal) → 报告(Report)
   ▲                                              │
   └──────────── 回归验证/学习回流 ────────────────┘
```

| 环节 | 输入 | 输出 | 工具链/脚本 |
| ------ | ------ | ------ | ------------- |
| 验证 | TEST-09 任务包、环境预检结果、用例注册表 | 原始执行结果 JSON/日志、环境可用性标记 | `hermes run`、`mq-smoke-test.sh`、`doc-self-check.sh` |
| 诊断 | 失败用例日志、退出码、环境快照 | 失败模式标签（容器/端口/积压/假阳性）、根因候选 | `hermes diagnose`、`journalctl`/`docker logs`、`kubectl describe` |
| 修复 | 诊断标签、L0-L3 自愈白名单 | 修复动作记录、配置快照 ID、人工审批单（L3） | `hermes fix`、git stash/snapshot、PR 模板 |
| 自愈 | 修复结果、回归用例集 | 回归通过/失败结论、quarantine 状态更新 | `hermes heal`、`doc-self-check.sh full`、TC-INT 回归集 |
| 报告 | 全量结果、修复记录、回归结论 | `summary.md`、批次报告片段、PROJECT_STATUS 输入 | `hermes report`、`Testing/self-check-history.log` |

闭环设计原则【论证】：

1. **可观测先于动作**：hermes 不自愈"看不懂"的失败；诊断阶段必须给日志、标签、候选根因。
2. **可逆优先**：所有自动修复动作必须能回滚；不可逆动作（如修改文档正文）必须人在回路。
3. **失败是输入**：一次修复后必须触发同场景回归，并把结论回流到 `self-check-history.log` 与批次报告。

## T.11.2 自愈授权分级 L0-L3

| 级别 | 名称 | 可执行操作 | 白名单（允许清单） | 人在回路要求 |
| ------ | ------ | ------------ | -------------------- | -------------- |
| L0 | 只报告 | 收集日志、打标签、生成告警/工单 | 读取日志/指标/容器状态；写结果 JSON | 所有处置由人工完成 |
| L1 | 可逆操作 | 重跑失败用例、清理测试残留容器/卷、释放端口、rotate 旧日志 | `docker/podman rm -f` 测试容器；`compose down -v`；`rm -rf results/<run>/` 未归档目录；kill 由测试启动的孤儿进程 | 自动执行，事后审计 |
| L2 | 配置修复 | 改测试/夹具配置、快照并回滚预案 | 改 `Testing/fixtures/*.yml`、改 `topics/config-templates/` 中测试专用副本、改 hermes 任务包参数 | 自动执行，配置变更须 diff 可见并生成回滚快照 |
| L3 | 内容修复 | 修改文档正文、用例断言、脚本代码 | 无自动白名单；必须走 PR/审批 | 事前审批，禁止机器自动合并 |

分级决策流程【论证】：

```bash
# hermes-self-heal.sh 决策骨架（示意）
DIAG=$1   # 诊断标签
LEVEL=L0  # 默认只报告

case "$DIAG" in
  container_stuck|port_conflict|leftover_volume|flaky_network)
    LEVEL=L1 ;;
  config_drift|fixture_outdated|env_timeout)
    LEVEL=L2 ;;
  doc_drift|test_assertion_bug|script_logic_bug)
    LEVEL=L3 ;;
  *)
    LEVEL=L0 ;;
esac

if [[ "$LEVEL" == "L3" ]]; then
  echo "L3_MANUAL_REVIEW_REQUIRED: $DIAG"
  exit 0
fi
# L1/L2 在审计日志中记录后执行
```

审计要求：所有 L1/L2 动作写入 `Testing/hermes-audit.log`，字段包括：时间戳、任务包 ID、用例 ID、诊断标签、执行动作、回滚命令、操作者（hermes/人工）。

## T.11.3 排障排错 runbook

常见失败模式映射表：

容器命令 podman/docker 等价（宿主默认 podman，见 TEST-09 宿主默认）；脚本化执行时用 `$RT` shim，表中 `docker` 替换为 `"$RT"` 即可。

| 失败模式 | 快速诊断命令 | 修复动作 | 自愈级别 |
| ---------- | -------------- | ---------- | ---------- |
| 容器起不来 | `docker logs <container>`、`docker inspect --format='{{.State.Error}}' <container>` | 检查镜像拉取/compose 语法；清除残留后重跑 | L1 |
| 端口冲突 | `ss -tlnp \| grep <port>`、`lsof -i :<port>` | kill 占用进程或换端口后重跑 | L1 |
| 消息积压/消费停滞 | `kafka-consumer-groups --describe` / `nats consumer info` / `rabbitmqctl list_queues` | 扩容消费者、检查消费异常、reset offset（测试环境允许） | L2 |
| 测试假阳性 | 同环境重跑 3 次，看失败率；对照 TEST-05 五问法 | 若稳定复现则按 P/T/E/D/B 分类；时序脆弱则加固断言 | L3 |
| 镜像拉取失败 | `docker pull <image>` 看网络/认证；检查镜像名版本 | 切备用 registry 或标记 SKIP | L1 |
| 磁盘/内存不足 | `df -h`、`free -m`、`docker system df` | 清理 dangling 镜像/卷；扩容或标记 SKIP | L1 |

诊断脚本示例（bash 代码块）：

```bash
#!/bin/bash
# hermes-diagnose.sh —— 常见失败模式诊断入口
CASE_ID=$1
ENV=$2
LOG=results/$PLAN_ID/$ENV-$CASE_ID.log
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"

diagnose_container() {
  local c=$("$RT" ps -aqf "name=$CASE_ID" | head -1)
  if [[ -z "$c" ]]; then echo "NO_CONTAINER"; return; fi
  "$RT" inspect --format='{{.State.Status}}|{{.State.ExitCode}}|{{.State.Error}}' "$c"
  "$RT" logs --tail 50 "$c" >> "$LOG"
}

diagnose_port() {
  local port=${3:-9092}
  if ss -tlnp | grep -q ":$port "; then
    echo "PORT_CONFLICT:$port"
    ss -tlnp | grep ":$port " >> "$LOG"
  else
    echo "PORT_OK:$port"
  fi
}

diagnose_lag() {
  local topic=${3:-test-topic}
  kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
    --describe --group "$CASE_ID" 2>/dev/null | tail -n +2
}

# 调用：./hermes-diagnose.sh TC-DEP-01 E2 9092
diagnose_container
```

修复动作示例（L1 级自动清理）：

```bash
#!/bin/bash
# hermes-fix-l1.sh —— 测试残留清理（仅在确认由本任务包创建时执行）
PLAN_ID=$1
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"
for label in "hermes.run=$PLAN_ID" "mq-test"; do
  "$RT" ps -qf "label=$label" | xargs -r "$RT" rm -f
  "$RT" volume ls -qf "label=$label" | xargs -r "$RT" volume rm -f
done
# 释放常见测试端口（确认无生产进程占用后）
for port in 9092 4222 5672 15672; do
  pid=$(ss -tlnp 2>/dev/null | grep ":$port " | sed -n 's/.*pid=\([0-9]*\).*/\1/p')
  [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
done
```

## T.11.4 自我更新/修正流程

当 hermes 执行失败且不归因于纯环境抖动时，触发自我修正闭环：

```text
测试失败
  ├─ hermes diagnose → 失败模式标签
  ├─ 按 TEST-05 分类：P（产品）/ E（环境）/ D（文档）/ T（用例）/ B（基准）
  ├─ 选择处置路径：
  │    E → L1 清理/重跑 → 仍失败则升级 E→P/T/D
  │    P → 开缺陷单，新增回归用例，人工修复
  │    T → L3：人工修用例断言，回归验证
  │    D → L3：人工修文档，doc-self-check full 回归
  │    B → 复核环境后更新基线（双人复核）
  └─ 回归验证 → 通过则关闭，失败则再诊断
```

文档修正子流程（D 类）：

| 步骤 | 动作 | 产出 |
| ------ | ------ | ------ |
| 1 | 截取"文档原文 vs 实测输出"对照 | D 类证据包 |
| 2 | 修改对应 md 文件，更新最后更新日期 | diff |
| 3 | 运行 `./topics/scripts/doc-self-check.sh full` | ERROR=0 |
| 4 | grep 同参数名在 topics/ 中其他出现位置 | 联动修正清单 |
| 5 | 在 TEST-05 双向修正登记表登记 | 闭环记录 |

L3 内容修复审批模板（Markdown 片段）：

```markdown
## hermes L3 修复审批单
- 任务包: nightly-2026-11-18
- 用例: TC-INT-09
- 分类: T（断言未考虑 MQTT QoS1 重连时序）
- 拟修改文件: Testing/02-集成用例/TEST-03-集成测试用例.md
- 回滚方案: git checkout 该文件上一提交
- 回归用例: TC-INT-09, TC-INT-10
- 审批人: __________  日期: __________
```

## T.11.5 执行栈失败收集与日志归档

podman/docker/k8s 三层执行栈的失败收集规范：

| 执行栈 | 必收日志 | 收集命令 | 保留时长 |
| -------- | ---------- | ---------- | ---------- |
| Podman (E1) | container log、podman events、compose 输出 | `podman logs <c>`、`podman events --since <t>` | 90 天 |
| Docker (E2) | container log、daemon log（测试相关段）、compose 输出 | `docker logs <c>`、`journalctl -u docker` | 90 天 |
| K8s (E3) | pod log、events、describe、controller 日志 | `kubectl logs <pod>`、`kubectl describe pod <pod>`、`kubectl get events` | 180 天 |

归档目录结构与命名规范：

```text
results/
└── 2026-11-18/
    ├── E2-TC-DEP-01.json
    ├── E2-TC-DEP-01.log
    ├── E2-TC-DEP-01.failbundle/       # 失败时才有
    │   ├── container-logs/
    │   │   ├── kafka-1.log
    │   │   └── kafka-2.log
    │   ├── resource-snapshot/
    │   │   ├── df.txt
    │   │   ├── docker-ps.txt
    │   │   └── docker-network-ls.txt
    │   └── diagnose-labels.txt        # 机器打的诊断标签
    └── summary.md
```

失败包生成脚本（bash 代码块）：

```bash
#!/bin/bash
# hermes-collect-failbundle.sh
PLAN_ID=$1; ENV=$2; CASE_ID=$3
BUNDLE="results/$PLAN_ID/$ENV-$CASE_ID.failbundle"
mkdir -p "$BUNDLE"/{container-logs,resource-snapshot}

# 容器日志（兼容 docker/podman，宿主默认 podman）
RUNTIME=${RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}
$RUNTIME ps -a --format '{{.Names}}' | grep -E "$CASE_ID|mq-test|hermes" | while read c; do
  $RUNTIME logs --tail 200 "$c" > "$BUNDLE/container-logs/$c.log" 2>&1 || true
done

# 资源快照
df -h > "$BUNDLE/resource-snapshot/df.txt"
$RUNTIME ps -a > "$BUNDLE/resource-snapshot/${RUNTIME}-ps.txt"
$RUNTIME network ls > "$BUNDLE/resource-snapshot/${RUNTIME}-network-ls.txt"

# 诊断标签（由 hermes-diagnose.sh 输出）
./hermes-diagnose.sh "$CASE_ID" "$ENV" > "$BUNDLE/diagnose-labels.txt"
```

## T.11.6 与现有文档的衔接

| 文档 | 衔接点 |
| ------ | -------- |
| TEST-05 | P/E/D/B 分类是 hermes 自我修正的归因输入；L3 修复单直接引用 TEST-05 的双向修正登记表 |
| TEST-06 | `doc-self-check.sh` / `mq-smoke-test.sh` 是 hermes 验证环节的工具链；回归验证必须复跑 full |
| TEST-08 | 覆盖矩阵决定哪些用例进入 hermes 任务包，进而影响自愈触发频率 |
| TEST-09 | 环境矩阵 E0-E3 是 hermes 执行闭环的运行域；任务包格式是闭环的输入 |
| TEST-10 | 用例编写规范决定失败日志是否包含足够诊断信息 |
| 01-56 | AIOps 智能运维为 hermes 的诊断/基线漂移提供分析层参考 |
| 01-33 | 自治分级（监测/告警/伸缩/自愈）为 L0-L3 授权分级提供概念基础 |

## T.11.7 参考来源

- 项目内：[TEST-05](../05-体系与机制/TEST-05-测试纠正与修正机制.md)、[TEST-06](../05-体系与机制/TEST-06-自我验证机制与脚本说明.md)、[TEST-08](TEST-08-文档用例脚本映射矩阵与覆盖规划.md)、[TEST-09](TEST-09-测试执行计划与环境矩阵.md)、[TEST-10](TEST-10-用例编写与执行规范.md)、[01-33](../../topics/01-基础概念与对比分析/01-33-可观测性与自治运维能力体系分析.md)、[01-56](../../topics/01-基础概念与对比分析/01-56-AIOps消息系统智能运维.md)
- 外部：[Podman 文档](https://docs.podman.io/)、[Docker 文档](https://docs.docker.com/)、[Kubernetes 故障排查](https://kubernetes.io/docs/tasks/debug/)

---

**最后更新**: 2026-11-18
