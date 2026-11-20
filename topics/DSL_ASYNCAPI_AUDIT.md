# DSL→AsyncAPI 全链覆盖审计报告

> **审计口径**: 状态=实测（打开文件/运行脚本）；版本事实=【论证】（以官方规范/项目文档为准）；未实测推断=【估算】。
> **时效声明**: 本文事实基于项目仓库当前状态核实至 2026-11。
> **本文档定位**: 元文档。对照"业务设计→DSL→AsyncAPI→绑定→多语言→测试验证"六环，逐环审计现有覆盖、标定缺口并给出补齐路线。不替代 TEST-C1/01-43/01-44/02-56，而是对其落地完整性的独立审计。

## 目录

- [DSL→AsyncAPI 全链覆盖审计报告](#dslasyncapi-全链覆盖审计报告)
  - [目录](#目录)
  - [审计方法与证据来源](#审计方法与证据来源)
  - [六环覆盖矩阵](#六环覆盖矩阵)
  - [逐环证据与缺口](#逐环证据与缺口)
    - [L1 业务设计→DSL](#l1-业务设计dsl)
    - [L2 DSL→AsyncAPI](#l2-dslasyncapi)
    - [L3 AsyncAPI→MQ 绑定](#l3-asyncapimq-绑定)
    - [L4 绑定→通信语义](#l4-绑定通信语义)
    - [L5 通信语义→业务场景](#l5-通信语义业务场景)
    - [L6 业务场景→测试验证](#l6-业务场景测试验证)
  - [关键审计发现实录](#关键审计发现实录)
  - [重点核查结论](#重点核查结论)
  - [缺口优先级排序](#缺口优先级排序)
  - [补齐路线图](#补齐路线图)
  - [本次已补齐文件清单](#本次已补齐文件清单)
  - [约束与未改动说明](#约束与未改动说明)
  - [附录：AsyncAPI 3.1.0 基线评估（批次 161，2026-11-18 核实）](#附录asyncapi-310-基线评估批次-1612026-11-18-核实)

---

## 审计方法与证据来源

1. **文档层**: 打开并核对 01-43、01-44、02-56、TEST-C1、TEST-C2、odcs-alignment.md、bindings-matrix.md。
2. **资产层**: 实地检查 `Testing/06-契约语义测试/` 下 6 系统 spec、8 场景契约包、`topics/scripts/` 相关脚本、`topics/examples/` 多语言示例。
3. **执行层**: 运行 `contract-spec-check.sh`、`contract-binding-check.sh`、`contract-drift-check.sh`、`tc-assert-check.sh`、`xlang-matrix.sh --validate` 并核对退出码与输出；用 `python3 jsonschema` 校验 8 个 `contract.yaml` 与新建 `dsl-schema.json`。

---

## 六环覆盖矩阵

| 六环 | 状态 | 证据（文件路径+行级锚） | 缺口描述 |
| ---- | ---- | ---------------------- | -------- |
| L1 业务设计→DSL | 🟡部分 | 01-43 方法论完整（§1.43.1 四步转换环，行 40-52）；8 场景 `contract.yaml` 存在；但**无正式 DSL schema** | 有写作规范，无机器可读的字段/类型约束；新增字段靠人工约定 |
| L2 DSL→AsyncAPI | 🟡部分 | 8 场景 `asyncapi.yaml` 存在，`$ref: 'contract.yaml#/messages/.../fields'` 外部引用 32 处；但**无生成器**，全手写 | 外部引用未在 spec-check 中解析；design→asyncapi 未工具化 |
| L3 AsyncAPI→MQ 绑定 | 🟡部分 | `bindings-matrix.md` 四级字段矩阵完整；`contract-binding-check.sh` 可执行；但 13 处 `bindingVersion` 缺失 | 场景包与模板未严格执行"每个 binding 声明 bindingVersion"（01-44 §1.44.7/02-56 §2.56.3） |
| L4 绑定→通信语义 | ✅完备 | TEST-C2 十二维度矩阵 + `semantics/assertions.tsv`（17 条 ASE）；`tc-assert-check.sh` 通过 | 静态层完整；E2 真实执行仍挂账 |
| L5 通信语义→业务场景 | 🟡部分 | 8 场景契约包完整，含 `x-semantics` 标注；但仅 01-order-lifecycle 有 `quality/sla` | ODCS 对齐段在 7/8 场景缺失 |
| L6 业务场景→测试验证 | 🟡部分 | E0 已接入 `contract-spec-check` + `tc-assert-check`；spec 版本差分工具已落地并入门禁（`topics/scripts/spec-diff-check.sh` + `Testing/asyncapi-tools/spec-diff.js`，@asyncapi/diff 0.6.1 库封装；批次180 双向实证 + **批次182 入 E0 第十一步**：版本对样本=仓内 v1 spec×v2-break fixture，self-diff RC=0 / fixture RC=1 breaking=3 回归断言，node 缺失 SKIP）；但**脚本路径硬编码旧目录**导致此前只查到 2 个模板 | 路径修复后覆盖全部 14 spec；**批次183 DSL schema 校验落地**（`spec-validate.js`+`spec-validate-check.sh`，@asyncapi/parser 3.6.6，16 spec 全量覆盖，schema/$ref 缺陷 8 件全修，全绿 RC=0+坏 $ref 负向对照 RC=1）；**批次184 入 E0 第十二步**；外部 $ref 解析、binding 层级违规未入 E0 |

---

## 逐环证据与缺口

### L1 业务设计→DSL

- **证据**: 01-43 给出 Event Storming/EIP/遗留代码/OpenAPI/BPMN 五源到 AsyncAPI DSL 的映射规则（§1.43.1 四步转换环，行 40-52；§1.43.2 色标映射，行 72-79；§1.43.3 EIP 三态映射，行 148-163）；8 个 `contract.yaml` 遵循统一头部（`scenario/version/messages/invariants`）。
- **实测**: `topics/scripts/contract-to-odcs.py --check` 对 8 个 contract 均返回 `CHECK_OK`；字段类型在 8 个文件中实际使用了 `string/number/integer/timestamp/array/object/boolean/enum`（如 `01-order-lifecycle/contract.yaml` 行 9-32）。
- **缺口**: 没有 `dsl-schema.json` 等正式定义；字段类型（`string/number/timestamp/array/object`）靠注释约定；`quality/sla` 段只有 01-order-lifecycle 实践（行 44-53），其余 7 个场景包未补齐（odcs-alignment.md §三 已指出但待落地）。

**schema 设计要点**: 本次补齐的 `dsl-schema.json` 采用 JSON Schema draft-07，约束 `scenario`（kebab-case）、`version`（semver）、`messages`（命令/事件/查询三分，字段类型白名单）、`invariants`（至少 1 条）、可选 `stateMachine/quality/sla`；`additionalProperties: false` 防止未登记字段漂移；`severity` 设为可选以兼容现有 01-order-lifecycle 范例。

### L2 DSL→AsyncAPI

- **证据**: 8 场景 `asyncapi.yaml` 均使用 `$ref: 'contract.yaml#/messages/<Name>/fields'` 引用 DSL 字段（如 `03-业务场景/01-order-lifecycle/asyncapi.yaml` 行 33、41、43；`03-业务场景/05-iot-telemetry/asyncapi.yaml` 行 48、54）；全库搜索 `contract-to-asyncapi` / `design-to-asyncapi` 无生成器脚本。
- **实测**: `contract-spec-check.sh` 修复路径后可解析 14 个 spec，但脚本内 `PY_CHECK` 只校验 YAML 结构、内部 `$ref` 与 binding 键名（行 34-74）；**不解析外部 `contract.yaml#` 引用**，也不校验被引用字段是否存在。
- **缺口**: 没有 `design→asyncapi` 生成器，转换靠手写；外部引用未纳入静态校验闭环。**勘误（批次183）**: 原审计称 `asyncapi-contract-skeleton.yaml` 行 32 用"非官方字段 `replicas` 而非 `replicationFactor`"系方向颠倒——@asyncapi/specs 包内 kafka binding 0.3.0/0.4.0/0.5.0 的 channel.json 官方字段集均为 `topic/partitions/replicas/topicConfiguration/bindingVersion`，`replicationFactor` 不存在于任何版本；skeleton 的 `replicas: 3` 为官方字段，真正违规的是 3 件 spec 使用 `replicationFactor`（批次183 已修为 `replicas`，parser 实证 16/16 全绿）。

### L3 AsyncAPI→MQ 绑定

- **证据**: `bindings-matrix.md` 给出 Kafka/MQTT/AMQP/NATS/Pulsar/Redis 四级字段白名单与 x- 扩展登记簿（§二、§三）；`contract-binding-check.sh` 行 26-88 已机器镜像该矩阵，含 MQTT channel 级保留空纠察。
- **实测**: 修复路径后 `contract-binding-check.sh` 对 14 个 spec 全 PASS；但脚本内 `OFFICIAL` 字典未将 `bindingVersion` 作为强制字段（仅作为白名单字段允许存在）。
- **缺口**: 13 处 binding 未声明 `bindingVersion`（如 `03-业务场景/01-order-lifecycle/asyncapi.yaml` 行 19-21 Kafka channel binding、`topics/config-templates/asyncapi-kafka-example.yaml` 行 23-32；`03-业务场景/04-notification/asyncapi.yaml` 行 21-28 AMQP channel binding）；**勘误（批次183）**: 原称 `asyncapi-contract-skeleton.yaml` 行 32 的 `replicas` 字段不在 Kafka binding 0.5.0 官方字段集系方向颠倒——`replicas` 为 0.3.0/0.4.0/0.5.0 全版本官方字段（@asyncapi/specs/bindings/kafka/*/channel.json 实证），非官方的是 3 件 spec（01-order-lifecycle/02-payment-reconciliation/asyncapi-kafka-example）曾用 `replicationFactor`（批次183 已修为 `replicas`）。

### L4 绑定→通信语义

- **证据**: TEST-C2 定义 12 语义维度 × 六系统能力矩阵（行 37-55）；`semantics/assertions.tsv` 含 17 条 GWT 断言（ASE-001~017）。
- **实测**: `tc-assert-check.sh` 修复路径后 `CHECKS=25 PASS=25 FAIL=0`。
- **缺口**: 静态资产完备，真实执行脚本仅 2 个（`tc-sem-05-dlq-rabbitmq.sh`、`tc-sem-07-backpressure-nats.sh`），其余 TC-SEM 仍 pending。

### L5 通信语义→业务场景

- **证据**: 8 场景包均含 `contract.yaml/asyncapi.yaml/SEMANTICS.md`；`asyncapi.yaml` 中 operations 均带 `x-semantics` 标注（如 08-task-queue 行 29 `x-semantics: [死信, 交付语义]`，行 36-39 `x-jetstream` 扩展）。
- **实测**: `tc-assert-check.sh`（行 14 `DIMS` 常量 + 行 53-55 校验逻辑）校验所有 `x-semantics` 值均属于 TEST-C1 规定的 12 维度清单。
- **缺口**: 仅 01-order-lifecycle 在 `contract.yaml` 中补充 `quality/sla` 段（odcs-alignment.md §三 范例，行 44-53），其余 7 场景缺失 ODCS 治理维度。

### L6 业务场景→测试验证

- **证据**: `hermes-e0-run.sh` 步骤 6/7 已接入 `contract-spec-check.sh` 与 `tc-assert-check.sh`（行 175-183）；`test-registry.tsv` 已注册 TC-SEM-01~12 与 TC-BUS-01~08（行 200-218）。
- **实测**: 修复前 4 个脚本均因 `SERIES_DIR="$PROJECT_ROOT/契约语义测试"` 硬编码旧目录而退化：`contract-spec-check` 只查到 2 个 config-template spec；`tc-assert-check` 直接报错找不到断言库。修复后 14 spec 与 25 项断言校验全绿。
- **缺口**: **批次183 DSL schema 校验工具已落地**（`Testing/asyncapi-tools/spec-validate.js`+`topics/scripts/spec-validate-check.sh`，@asyncapi/parser 3.6.6 封装，16 spec 全量覆盖 schema/$ref/binding 字段校验，双向实证：修复后全绿 RC=0 + 注入坏 $ref 门真红 RC=1；同批修复 8 件 spec 缺陷：坏 $ref×4 处（JSON pointer `%2F` 转义）/`replicationFactor` 非官方字段×3 件/`cleanup.policy` 非数组×1 件/amqp routingKey 分支误带 queue×1 件/inventory kafka binding 缩进错位×1 件）；**批次184 已入 E0 第十二步**（`hermes-e0-run.sh` 十二步全量门禁，12/12 执行，node 缺失 SKIP）；`contract-spec-check` 不检查外部 $ref 与 `bindingVersion`；跨语言金样本矩阵 `xlang-matrix.sh` 仍是占位骨架，`--live` 未实现；spec 版本差分已入 E0 第十一步（批次182：版本对样本=仓内 v1 spec×v2-break fixture，回归断言 self RC=0/fixture RC=1 breaking=3，node 缺失 SKIP）。

---

## 关键审计发现实录

以下输出截取自本次审计实际执行，用以佐证矩阵中的"状态"列。

```text
# 修复路径前：contract-spec-check 仅覆盖 2 个 config-template spec
$ bash topics/scripts/contract-spec-check.sh --json
SPECS=2 PASS=2 FAIL=0
{"total":2,"pass":2,"fail":0}

# 修复路径后：覆盖 6 系统 spec + 8 场景 asyncapi + 2 模板 = 14 spec
$ bash topics/scripts/contract-spec-check.sh --json
SPECS=14 PASS=14 FAIL=0
{"total":14,"pass":14,"fail":0}

# tc-assert-check 修复路径后
$ bash topics/scripts/tc-assert-check.sh --json
CHECKS=25 PASS=25 FAIL=0

# 新建 dsl-schema 校验 8 个 contract.yaml
$ bash topics/scripts/contract-dsl-check.sh --json
PASS=8 FAIL=0 ERROR=0
{"pass":8,"fail":0,"error":0}

# xlang-matrix 仍为占位
$ bash topics/scripts/xlang-matrix.sh --validate
VALIDATE_OK boundary_cases=6
VALIDATE_OK boundary_cases=4
VALIDATE_OK boundary_cases=4
$ bash topics/scripts/xlang-matrix.sh --live
LIVE：全配对执行骨架就位（ fixtures 多语言容器 + Microcks 断言流随真实批次落地）
exit 2
```

**批次183 实录**（spec-validate 落地 + spec 缺陷修复）:

```text
# 修复前：16 件中 8 件存在 schema/$ref 缺陷
$ bash topics/scripts/spec-validate-check.sh
汇总: 8/16 存在 schema 缺陷
[spec-validate] ❌ AsyncAPI schema 校验失败 (RC=1)
# 缺陷明细: 坏 $ref×4 处（pulsar/audit-trail 通道键含 / 未做 JSON pointer %2F 转义）
#          replicationFactor 非官方字段×3 件（kafka binding 0.5.0 官方=replicas）
#          cleanup.policy 非数组×1 件（skeleton 模板）
#          amqp routingKey 分支误带 queue×1 件（oneOf 分支互斥）
#          inventory kafka binding 缩进错位×1 件（partitions 落 channel 根）

# 修复后：16/16 全绿
$ bash topics/scripts/spec-validate-check.sh
汇总: 16/16 通过 (RC=0)
[spec-validate] ✅ AsyncAPI schema 校验通过

# 负向对照：注入坏 $ref 后门真红（复原后仅余真实修复）
$ sed -i 's|%2Forder-events|%2Fnonexistent|g' .../asyncapi-pulsar-example.yaml
$ bash topics/scripts/spec-validate-check.sh
汇总: 1/16 存在 schema 缺陷
[spec-validate] ❌ AsyncAPI schema 校验失败 (RC=1)
```

**影响评估**: 路径错误导致 E0 步骤 6/7 自批次 53 目录重命名后实际覆盖范围从设计的"6 系统 spec + 8 场景 asyncapi + 2 模板"退化为"2 个模板"，`test-registry.tsv` 中 8 个 TC-BUS 用例的 E0 静态校验事实上未执行。修复后 `contract-spec-check` 与 `contract-binding-check` 各覆盖 14 个 spec，`tc-assert-check` 覆盖 25 项断言，全绿通过。

---

## 重点核查结论

1. **DSL 语法无正式 schema（P0）**
   - 01-43 是方法论文档，无机器可读 schema；contract.yaml 字段规则散见于 8 个场景文件与 odcs-alignment.md。
   - **补齐**: 已新建 `Testing/06-契约语义测试/01-契约规格/dsl-schema.json`，并经验证 8 个 contract.yaml 全通过 schema 校验。

2. **AsyncAPI 生成未工具化（P1）**
   - 8 场景 asyncapi.yaml 全手写，无 design→asyncapi 生成器；01-32 提到 Modelina/Generator，但项目未落地从 contract.yaml 自动生成 AsyncAPI 的脚本。

3. **多语言生成链停留在示例（P1）**
   - `topics/examples/asyncapi-generated-producer-example.py` 是手写"Modelina 风格"代码，非真实生成物；`topics/examples/01-编程语言对比分析.md` 存在重复章节号（如 6.2、7.8 等占位），缺少跨语言类型语义对照矩阵；`xlang-matrix.sh --live` 挂账。

4. **测试验证闭环有结构性缺口（P0/P1）**
   - P0: 4 个脚本硬编码旧目录 `契约语义测试`，导致 E0 长期只查 2 个模板。根因是批次 53 将目录从 `契约语义测试` 重命名为 `Testing/06-契约语义测试` 后未同步脚本（`git status` 显示 rename 记录）。已修复为 `Testing/06-契约语义测试`。
   - P1: `contract-spec-check` 只查内部 `$ref`，不解析 `contract.yaml#` 外部引用；不检查 `bindingVersion`；`contract-binding-check` 对未声明 bindingVersion 不告警。

5. **ODCS 对齐仅 1/8 场景落地（P1）**
   - odcs-alignment.md §三 以 01-order-lifecycle 为范例要求 8 场景补 `quality/sla`，但 02~08 场景包尚未执行；`contract-to-odcs.py` 对缺失段输出空对象，不报错，导致静态门禁无法拦截。

---

## 缺口优先级排序

| 优先级 | 缺口 | 影响 | 是否本次补齐 |
| ------ | ---- | ---- | ------------ |
| P0 | 脚本 `SERIES_DIR` 硬编码旧目录，E0 契约检查失效 | 全链可信度崩塌；test-registry 中 TC-BUS 静态校验实际未跑 | ✅ 已修复 4 脚本 |
| P0 | contract.yaml 无正式 schema，DSL 字段约束不可机读 | L1 层无法做静态门禁；新增字段易漂移 | ✅ 已新建 dsl-schema.json + contract-dsl-check.sh |
| P1 | 13 处 binding 未声明 `bindingVersion` | 违反 01-44/02-56 治理规则；不同工具解释不一致 | 未改（现有文档/模板） |
| P1 | `contract-spec-check` 不解析外部 `$ref: contract.yaml#` | payload 字段变更无法被 E0 捕获 | 未改 |
| P1 | 7/8 场景包缺失 `quality/sla` ODCS 段 | ODCS 对齐不完整 | 未改 |
| P1 | 无 design→asyncapi 生成器 | 转换靠手写，效率低、易出错 | 未改 |
| P2 | 跨语言金样本矩阵未实跑 | 01-77 提出的 5 语言对等验证停留在规划 | 未改 |
| P2 | ~~`asyncapi-contract-skeleton.yaml` 用非官方 `replicas` 字段~~ **勘误（批次183）：方向颠倒**，`replicas` 为官方字段；真正违规=3 件 spec 用 `replicationFactor` | 模板无冲突；3 spec 与官方 schema 冲突 | ✅ 批次183 已修 3 件 spec（`replicationFactor`→`replicas`）+ skeleton `cleanup.policy` 数组化，16/16 全绿 |

---

## 补齐路线图

| 缺口 | 建议批次 | 产出物 | 验收标准 |
| ---- | -------- | ------ | -------- |
| P0 脚本路径 | 本次（审计批） | `topics/scripts/contract-{spec,binding,drift}-check.sh`、`tc-assert-check.sh` 路径修复 | E0 步骤 6/7 覆盖 14 spec + 25 断言，全绿 |
| P0 DSL schema | 本次（审计批） | `Testing/06-契约语义测试/01-契约规格/dsl-schema.json`、`topics/scripts/contract-dsl-check.sh` | 8 contract.yaml 全通过 schema 校验；`python3 -c json` 通过 |
| P1 bindingVersion | 批次 94 | 批量修复 8 场景 + 2 模板 bindingVersion；`contract-binding-check.sh` 增加必填检查 | `contract-binding-check` 对缺失 bindingVersion 报错 |
| P1 外部 $ref 解析 | 批次 94 | `contract-spec-check.sh` 增加 `contract.yaml#` 存在性与字段存在检查 | 删除/重命名字段后 E0 立即 FAIL |
| P1 ODCS 段补齐 | 批次 94 | 02~08 场景包 contract.yaml 补 quality/sla | `contract-to-odcs.py --check` 全绿且导出 YAML 结构一致 |
| P1 生成器 | 批次 95 | `contract-to-asyncapi.py`（contract.yaml → asyncapi.yaml 骨架） | 输入 01-order-lifecycle contract，输出与现有 asyncapi.yaml 结构等价 |
| P2 跨语言矩阵 | 批次 100（原挂账） | `xlang-matrix.sh --live` + fixtures 多语言容器 + 金样本集扩至 8 场景 | 5 语言两两全配对 20 条边跑通 |
| P2 模板字段修正 | 批次 94 | ~~skeleton `replicas` → `replicationFactor`~~ **勘误（批次183）：方向颠倒，skeleton 本就正确**；实际修 3 件 spec `replicationFactor`→`replicas` + skeleton `cleanup.policy` 数组化 + spec-validate 门落地 | ✅ 批次183 spec-validate 16/16 全绿（RC=0），门=`topics/scripts/spec-validate-check.sh`（未入 E0） |
| P2 Spectral 规则补全 | 批次 94 | 在 `topics/config-templates/spectral-asyncapi-ruleset.yaml` 增加 `binding-version-required` 规则 | `spectral lint` 对缺失 bindingVersion 报错 |

---

## 本次已补齐文件清单

1. **修复脚本**（路径错误，4 个文件）
   - `topics/scripts/contract-spec-check.sh`
   - `topics/scripts/contract-binding-check.sh`
   - `topics/scripts/contract-drift-check.sh`
   - `topics/scripts/tc-assert-check.sh`

2. **新增 DSL schema 与校验器**（2 个文件）
   - `Testing/06-契约语义测试/01-契约规格/dsl-schema.json`
   - `topics/scripts/contract-dsl-check.sh`

3. **审计主文档**（1 个文件）
   - `topics/DSL_ASYNCAPI_AUDIT.md`

---

## 约束与未改动说明

- **未修改 INDEX/STATUS/ROADMAP/CHANGELOG/AGENTS.md** 及现有 topic 正文，符合任务硬约束。
- **未修改 8 场景 asyncapi.yaml / contract.yaml 与 config-templates**：P1 级 bindingVersion 缺失、`replicas` 字段误用、7 场景 quality/sla 缺失已在矩阵与路线图中标出，留待后续批次按变更流程处理。
- **未改动 hermes-e0-run.sh 步骤编排**：新增 `contract-dsl-check.sh` 作为独立工具交付，是否接入 E0 由批次四件套统一决策。

---

**最后更新**: 2026-11-21（批次182：spec 版本差分入 E0 第十一步+版本对样本落仓）


## 附录：AsyncAPI 3.1.0 基线评估（批次 161，2026-11-18 核实）

**事实**（[官方 release notes](https://www.asyncapi.com/blog/release-notes-3.1.0)，2026-01-31）：3.1.0 为 minor  release，**零破坏性变更**——`asyncapi: '3.0.0'` 直接改为 `'3.1.0'` 文档保持有效；唯一实质新增=**ROS 2 bindings**（机器人域，与六系统无关；bindings-matrix 索引已含）。

**处置结论**【论证】：

1. 本库 14 个 spec **无需批量修改**（无行为差异，改动纯属版本号噪音）；
2. **新文档默认声明 3.1.0**（对齐当前版，防工具链新旧校验歧义）——入 CONTRACT_DESIGN_SPEC §一 补充条款；
3. contract-spec-check 的版本校验维持 `3.` 前缀匹配（已兼容），无需变更；
4. ROS 2 binding 不纳入六系统矩阵（超出范围声明，防范围蔓延）。
