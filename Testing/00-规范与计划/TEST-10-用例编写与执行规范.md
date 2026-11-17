# T.10 用例编写与执行规范

> **本文档定位**：统一项目用例的 ID、格式、脚本规范、结果判定与统计口径，使本地执行者 hermes 能够解析并执行。所有 TEST-02/03/04/07 新增用例须遵守本文约定。

## 目录

- [T.10 用例编写与执行规范](#t10-用例编写与执行规范)
  - [目录](#目录)
  - [T.10.1 用例 ID 规范](#t101-用例-id-规范)
  - [T.10.2 用例文档格式](#t102-用例文档格式)
  - [T.10.3 脚本编写规范](#t103-脚本编写规范)
  - [T.10.4 结果判定](#t104-结果判定)
  - [T.10.5 统计口径](#t105-统计口径)
  - [T.10.6 与现有文档的衔接](#t106-与现有文档的衔接)
  - [T.10.7 参考来源](#t107-参考来源)

---

## T.10.1 用例 ID 规范

格式：`TC-<域>-<NN><后缀>`

- 域：DEP（部署）、INT（集成）、CLU（集群）、OBS（可观测）、SEC（安全）、CON（一致性）。
- NN：两位数字，01~99，每域独立编号。
- 后缀：可选小写字母，用于同域变体（如 TC-DEP-04c 表示 RocketMQ 变体）。

编号唯一性与分配规则：

- 新增用例必须先在 TEST-08 覆盖矩阵中占格，再分配 ID；
- 同域下编号按创建顺序递增，不得跳号；
- 变体后缀按系统或场景字母顺序分配（b=Redis/MQTT, c=RocketMQ, d=Redpanda）；
- 已删除用例的 ID 永久冻结，不得复用，防止历史结果混淆。

ID 分配示例：

| 用例 | 域 | 编号理由 |
| ------ | ----- | ---------- |
| TC-DEP-01 | 部署 | 部署域第 1 号 |
| TC-DEP-04c | 部署 | 第 4 号 RocketMQ 变体 |
| TC-INT-08b | 集成 | 第 8 号 RocketMQ 变体 |
| TC-CLU-06c | 集群 | 第 6 号 Redpanda 变体 |
| TC-OBS-04 | 可观测 | 可观测域第 4 号 |

## T.10.2 用例文档格式

每用例固定字段，缺失任一字段视为格式缺陷。

````markdown
### TC-<域>-<NN> <名称>

- **目的**: 一句话说明验证什么
- **前置条件**: 环境/工具/数据前提；无环境时如何 SKIP
- **步骤**: 编号命令序列，可复制执行
  ```bash
  # 示例
  docker compose -f topics/config-templates/docker-compose-kafka.yml up -d
  ```
- **预期输出**: 每步命令输出要点
- **通过标准**: 量化判定，禁止"正常""无误"
- **失败处置**: 按 TEST-05 分类预设（P/T/E/D/B）
- **环境标签**: E0/E1/E2/E3
- **对应脚本**: ./topics/scripts/xxx.sh
- **对应文档**: `XX-XX-名称.md`（填写实际被验证的文档路径，如 `../02-场景驱动架构设计/02-14-消息去重策略.md`）
````

字段说明：

- 环境标签允许多个（如 E1/E2），表示该用例可在多个环境执行；
- 对应脚本为空时须注明"手工步骤"；
- 失败处置至少给出一个最可能分类，实际执行时按 TEST-05 五问修正。

## T.10.3 脚本编写规范

所有 `*-test.sh` 脚本必须遵守：

1. **bash 严格模式**：`set -euo pipefail` 或显式错误处理，禁止裸 `set -e` 后吞掉具体错误码。
2. **退出码约定**：
   - 0 = PASS
   - 1 = FAIL
   - 2 = SKIP
   - 3 = 环境缺失（hermes 将其映射为 SKIP 并记录缺失原因）
3. **输出规范**：脚本最后三行固定输出：

   ```text
   RESULT: PASS
   DURATION: 45
   EXIT_CODE: 0
   ```

4. **无副作用原则**：不删生产数据、不改生产配置；测试 topic/队列/流必须加前缀 `test-` 或 `tc-`；清理动作限制在本用例创建的命名空间/卷。

示例骨架：

```bash
#!/bin/bash
set -euo pipefail
START=$(date +%s)
RESULT="PASS"
EXIT_CODE=0

cleanup() {
  docker compose -f topics/config-templates/docker-compose-kafka.yml down -v >/dev/null 2>&1 || true
}
trap cleanup EXIT

# 环境预检
if ! docker compose version >/dev/null 2>&1; then
  echo "RESULT: SKIP"
  echo "DURATION: $(( $(date +%s) - START ))"
  echo "EXIT_CODE: 2"
  exit 2
fi

# 用例主体
...

echo "RESULT: $RESULT"
echo "DURATION: $(( $(date +%s) - START ))"
echo "EXIT_CODE: $EXIT_CODE"
```

常见错误处理模式：

```bash
# 模式 1：命令失败即 FAIL
some_command || { RESULT="FAIL"; EXIT_CODE=1; }

# 模式 2：环境缺失即 SKIP
command -v kubectl >/dev/null || { RESULT="SKIP"; EXIT_CODE=2; }

# 模式 3：可重试网络失败（对应 T.10.4 重试规则）
for i in 1 2; do
  curl -fsS http://localhost:9090/ready && break
  sleep 5
done || { RESULT="FAIL"; EXIT_CODE=1; }
```

## T.10.4 结果判定

四态定义与转换规则：

| 状态 | 定义 | 转换规则 |
| ------ | ------ | ---------- |
| PASS | 通过标准全部满足 | — |
| FAIL | 通过标准任一未满足 | 须按 TEST-05 分类 |
| SKIP | 环境缺失或用例不适用 | 环境缺失不得记为 FAIL |
| BLOCK | 前置条件严重失败导致无法继续 | 转为 SKIP 或 FAIL 前须经人工确认 |

重试规则：

- 网络类失败（连接超时、瞬断）重试 1 次，间隔 5s；
- 重试后仍失败按 FAIL 处理；
- 非确定性时序失败须先按 E 类（环境抖动）调查，连续 3 次复现才定性。

## T.10.5 统计口径

与 TEST-08 覆盖口径衔接：

- **执行率** = 当期实际执行用例数 / 当期计划执行用例数 × 100%
- **通过率** = PASS 数 / 实际执行数 × 100%（SKIP 不计入分母）
- **缺口率** = 计划执行数 - 实际执行数 / 计划执行数 × 100%

示例：

```text
周期: weekly-2026-11-18
计划执行: 20
实际执行: 18（2 例因 E3 缺失 SKIP）
PASS: 17
FAIL: 1
执行率 = 18/20 = 90%
通过率 = 17/18 = 94.4%
缺口率 = 2/20 = 10%
```

批次报告固定格式（hermes 自动生成，与 TEST-09 产物校验规则衔接）：

```text
周期: weekly-2026-11-18
环境: E2
计划: 20, 执行: 18, PASS: 17, FAIL: 1, SKIP: 2
执行率: 90.0%, 通过率: 94.4%, 缺口率: 10.0%
失败用例: TC-INT-11 (分类: E, 原因: Toxiproxy 端口冲突)
SKIP 清单: TC-CLU-07(E3 缺失), TC-OBS-08(KEDA 未安装)
```

统计口径约束：

- 同一用例在同一周期内多次执行只取最后一次结果；
- 环境缺失导致的 SKIP 计入缺口率，但不计入通过率分母；
- 隔离区用例不计入任何统计，直到回归主流程。

## T.10.6 与现有文档的衔接

| 文档 | 衔接点 |
| ------ | -------- |
| TEST-05 | 失败处置分类与五问流程 |
| TEST-06 | 脚本输出规范与自检机制 |
| TEST-08 | 覆盖矩阵是 ID 分配与统计口径的输入 |
| TEST-09 | 环境标签决定用例进入哪个任务包 |

## T.10.7 参考来源

- 项目内：[TEST-05](../05-体系与机制/TEST-05-测试纠正与修正机制.md)、[TEST-06](../05-体系与机制/TEST-06-自我验证机制与脚本说明.md)、[TEST-08](TEST-08-文档用例脚本映射矩阵与覆盖规划.md)、[TEST-09](TEST-09-测试执行计划与环境矩阵.md)、[AGENTS.md](../../AGENTS.md) §3.2
- 外部：[ShellCheck Bash 严格模式指南](https://www.shellcheck.net/)、[POSIX 退出码约定](https://tldp.org/LDP/abs/html/exitcodes.html)

---

**最后更新**: 2026-11-18
