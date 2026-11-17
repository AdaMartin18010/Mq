# T.12 企业应用场景端到端用例库

> **置信口径**: 协议/规范语义=【定理】；架构对比与工程推理=【论证】；正文未单独标注的具体数字（阈值/百分比/时长）按【估算】理解（AGENTS.md §4.1，P3 基线声明）。
> **时效声明**: 本文事实基于项目现有 config-templates 与示例脚本核实至 2026-11；金融业务示例为示意性合成案例，非真实机构数据。
> **本文档定位**: 集成层业务场景维度端到端用例库——从电商、金融、IoT 三个企业级场景出发，验证消息系统对 Saga、强一致、审计、产业标准协议的实际支撑。技术维度用例见 [TEST-03](TEST-03-集成测试用例.md)；设计原理见 [02-47](../../topics/02-场景驱动架构设计/02-47-企业集成模式与事务消息模式.md)。

## 目录

- [T.12 企业应用场景端到端用例库](#t12-企业应用场景端到端用例库)
  - [目录](#目录)
  - [T.12.1 范围与分工声明](#t121-范围与分工声明)
  - [T.12.2 电商订单全链路](#t122-电商订单全链路)
  - [T.12.3 金融转账](#t123-金融转账)
  - [T.12.4 IoT 遥测](#t124-iot-遥测)
  - [T.12.5 失败处置预设](#t125-失败处置预设)
  - [T.12.6 公共检查清单](#t126-公共检查清单)
  - [T.12.7 参考来源](#t127-参考来源)
  - [T.12.8 通用业务场景契约库（L5 互链）](#t128-通用业务场景契约库l5-互链)

---

## T.12.1 范围与分工声明

**与 TEST-03 的分工**：

| 维度 | TEST-03 | TEST-12（本文） |
| ------ | --------- | ----------------- |
| 视角 | 技术语义（不丢、不重、顺序、事务、兼容） | 业务场景（订单、支付、转账、设备遥测） |
| 用例 ID | TC-INT-01~12 等 | TC-BIZ-01~09 |
| 验证目标 | 消息系统能力本身 | 消息系统支撑特定业务流程的正确性 |
| 依赖 | 单系统或多系统互通 | 通常跨多个 topic/队列/微服务/编排器 |
| 典型断言 | 消费数 = 发送数 | 业务状态机最终一致、审计日志完整、补偿成功 |

TC-BIZ 用例默认复用 TEST-03 已验证过的技术基线（如 acks=all、幂等生产者、read_committed），本文只描述业务层编排与断言。

> 诚实口径：TC-BIZ-05~08 金融转账用例为合成案例，用于验证消息系统对 ISO 20022 报文流、幂等、冲正的技术支撑，不代表真实银行核心系统测试。

## T.12.2 电商订单全链路

业务流（mermaid 文本版）：

```text
下单服务 --OrderCreated--> 订单 topic
支付服务 --PaymentCompleted--> 支付 topic
库存服务 --InventoryReserved--> 库存 topic
履约服务 --FulfillmentStarted--> 履约 topic
         ←--Saga 补偿（支付失败/库存不足）--
```

涉及系统映射表：

| 业务步骤 | 事件/命令 topic | 消息系统角色 | 关键语义 |
| ---------- | ----------------- | -------------- | ---------- |
| 下单 | `orders.created.v1` | Kafka：事件总线，持久化订单生命周期 | 顺序、可审计 |
| 支付 | `payments.status.v1` | RabbitMQ：支付回调队列（需可靠投递） | 幂等、补偿 |
| 库存 | `inventory.reserved.v1` | NATS JetStream：库存状态流 | 低延迟、状态同步 |
| 履约 | `fulfillment.started.v1` | Kafka：履约触发 + 对账 topic | 最终一致 |
| 补偿 | `orders.compensated.v1` | 编排器/ Saga 协调 | 补偿事务可追踪 |

用例表（电商）：

| ID | 前置条件 | 步骤 | 断言 | 环境 |
| ---- | ---------- | ------ | ------ | ------ |
| TC-BIZ-01 下单-支付-履约 happy path | 夹具 `test-data-orders.json` 已加载；Kafka/RabbitMQ/NATS 三系统 ready | 1. 发 OrderCreated 10 条 2. 模拟支付成功 3. 库存预留 4. 触发履约 | 订单最终状态=SHIPPED；无补偿事件；对账 topic 记录数=10 | E2 |
| TC-BIZ-02 支付失败 Saga 补偿 | 同 TC-BIZ-01；支付服务第 5 条返回失败 | 1. 发 10 条订单 2. 第 5 条支付失败触发补偿 3. 监听补偿事件 | 第 5 条订单状态=CANSELLED；库存释放事件出现；其余 9 条正常履约 | E2 |
| TC-BIZ-03 库存不足部分失败 | 库存服务对 SKU-A 设上限 5 | 1. 发 10 条含 SKU-A 的订单 2. 第 6 条起库存不足触发补偿 | 前 5 条履约成功；后 5 条进入补偿；对账 topic 差额=0 | E2 |
| TC-BIZ-04 订单乱序幂等校验 | 同一 orderId 重复发创建事件 | 1. 对同一 orderId 发送 3 次 OrderCreated 2. 后续流程推进 | 业务库中该 orderId 只生成 1 条订单；幂等键生效 | E1/E2 |

数据夹具需求：

- `Testing/fixtures/test-data-orders.json`：10 条订单，含正常单、高金额单、SKU-A 超限单、重复 orderId。
- `Testing/fixtures/docker-compose-test-env.yml`：三系统最小共存环境。

Saga 补偿断言脚本（bash 代码块）：

```bash
#!/bin/bash
# biz-ecommerce-saga-check.sh
ORDER_ID=$1
# 1. 订单状态最终一致
state=$(kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic orders.status.v1 --from-beginning --max-messages 1000 \
  --property print.key=true | grep "^$ORDER_ID" | tail -1 | awk '{print $NF}')
[[ "$state" == "CANCELLED" ]] || { echo "FAIL: state=$state"; exit 1; }
# 2. 库存释放事件存在
nats sub --queue hermes --subject inventory.released.v1 --count 1 --timeout 5s | grep "$ORDER_ID"
# 3. 对账差额为 0
diff=$(kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic reconciliation.v1 --from-beginning --max-messages 1000 | awk -F',' '{s+=$3}END{print s}')
[[ "$diff" == "0" ]] && echo "PASS" || echo "FAIL: diff=$diff"
```

## T.12.3 金融转账

> 本节为「示意性合成案例】，不指向任何真实金融机构。

业务流（mermaid 文本版）：

```text
付款行 --pacs.008 (FIToFICustomerCreditTransfer)--> 支付网关
支付网关 --PaymentStatusChanged--> Kafka topic
       --pacs.002 (PaymentStatusReport)--> 清算系统
审计服务 --AuditLog--> 审计 topic
冲正服务 --pacs.004 (PaymentReturn)--> 冲正队列
```

涉及系统映射表：

| 业务对象 | 消息/事件 | 消息系统角色 | 关键语义 |
| ---------- | ----------- | -------------- | ---------- |
| 贷记转账指令 | `pacs.008` 报文 | Kafka：高吞吐指令入口 | 顺序、不可丢失 |
| 支付状态事件 | `payments.status.changed.v1` | Kafka：状态机事件化（参考 01-45 ISO 20022 映射） | exactly-once、审计 |
| 状态报告 | `pacs.002` 报文 | RabbitMQ：对账队列 | 可靠投递、死信 |
| 冲正 | `pacs.004` 报文 | 专用冲正 topic/队列 | 强一致、幂等 |
| 审计日志 | `audit.payments.v1` | Kafka：不可变审计流 | 完整性、可回溯 |

用例表（金融）：

| ID | 前置条件 | 步骤 | 断言 | 环境 |
| ---- | ---------- | ------ | ------ | ------ |
| TC-BIZ-05 贷记转账 happy path | 付款行/收款行模拟器 ready；ISO 20022 报文夹具加载 | 1. 发 pacs.008 100 条 2. 模拟清算成功 3. 收 pacs.002 | 状态机终态=ACSC（已清算）；审计 topic 数=100；无重复清算 | E2 |
| TC-BIZ-06 重复提交幂等 | 同 TC-BIZ-05；对同一 MsgId 重发 3 次 | 1. 重发同一 pacs.008 3 次 2. 等待清算 | 业务侧只产生 1 笔账务；审计 topic 记录 3 次请求但 1 次清算 | E2 |
| TC-BIZ-07 冲正流程 | TC-BIZ-05 完成后对其中 5 条发起 pacs.004 | 1. 发 pacs.004 5 条 2. 监听冲正确认 | 原 5 条状态=RVSD；总账务差额=0；审计链完整 | E2 |
| TC-BIZ-08 状态报告延迟/丢失恢复 | 人为 drop 10% pacs.002 | 1. 发起 100 条转账 2. 模拟 10% 状态报告丢失 3. 触发对账重发 | 最终 100 条状态均收敛；无孤儿转账 | E3 |

ISO 20022 报文夹具校验（bash 代码块）：

```bash
#!/bin/bash
# biz-financial-iso20022-check.sh
MSG_FILE=$1
# 1. MsgId 唯一且符合 UUID/机构约定
msgid=$(xmllint --xpath '//*[local-name()="MsgId"]/text()' "$MSG_FILE")
[[ -n "$msgid" ]] || { echo "FAIL: MsgId missing"; exit 1; }
# 2. pacs.008 必须含 EndToEndId、InstdAmt、CdtrAgt
for tag in EndToEndId InstdAmt CdtrAgt; do
  xmllint --xpath "//*[local-name()=\"$tag\"]" "$MSG_FILE" >/dev/null || { echo "FAIL: $tag missing"; exit 1; }
done
# 3. 状态机事件必须携带 ISO 20022 原始报文引用
grep -q "OriginalMsgId:$msgid" "$MSG_FILE" && echo "PASS" || echo "FAIL: no original reference"
```

## T.12.4 IoT 遥测

业务流（mermaid 文本版）：

```text
边缘设备 --NBIRTH/DDATA (Sparkplug B)--> MQTT Broker
边缘网关 --聚合/压缩--> NATS JetStream
云平台 --分析/告警--> Kafka 分析 topic
        --NCMD/DCMD--> 设备命令下发
```

涉及系统映射表：

| 业务步骤 | 协议/系统 | 消息系统角色 | 关键语义 |
| ---------- | ----------- | -------------- | ---------- |
| 设备接入 | MQTT + Sparkplug B | MQTT broker：海量设备连接、遗嘱 | 会话状态、出生/死亡证书 |
| 边缘聚合 | NATS JetStream | 边缘网关本地缓冲、聚合上云 | 断网续传、顺序 |
| 云分析 | Kafka | 时序/告警分析入口 | 高吞吐、可回溯 |
| 命令下发 | MQTT + Sparkplug NCMD/DCMD | 可靠命令下发 | 至少一次、超时重试 |

用例表（IoT）：

| ID | 前置条件 | 步骤 | 断言 | 环境 |
| ---- | ---------- | ------ | ------ | ------ |
| TC-BIZ-09 设备上线-遥测-离线 | MQTT broker + NATS ready；Sparkplug B 主题命名空间正确 | 1. 设备发 NBIRTH 2. 发 DDATA 50 条 3. 断开连接触发 NDEATH | 平台收到 50 条遥测；设备状态=offline；最后已知值保留 | E1/E2 |
| TC-BIZ-10 边缘断网续传 | NATS JetStream 配置为文件存储 | 1. 网关发 100 条遥测 2. 断 NATS 与云链路 30s 3. 恢复链路 | 云端收到的遥测总数=100；断网期间数据无丢失、顺序符合时间戳 | E2 |
| TC-BIZ-11 命令下发与回执 | 设备已在线 | 1. 平台发 NCMD 重启命令 2. 设备执行后回执 | 命令 topic 与回执 topic 一一对应；超 30s 无回执进死信 | E2 |
| TC-BIZ-12 遥测乱序与去重 | 模拟网络抖动导致 DDATA 乱序/重复 | 1. 发 20 条带序列号但乱序的 DDATA 2. 部分重复 | 云端按序列号去重后 20 条；乱序在窗口内被重排 | E2 |

说明：TC-BIZ-09~12 默认使用 MQTT QoS 1 与 NATS JetStream 持久化；若测试环境资源受限，可将 TC-BIZ-10 的断网时长从 30s 缩短为 10s，并在结果中注明"资源受限下的最小续传验证"。

Sparkplug B 主题检查（bash 代码块）：

```bash
#!/bin/bash
# biz-iot-sparkplug-check.sh
GROUP_ID="plant01"; EDGE_NODE="edge-001"; DEVICE_ID="sensor-temp-01"
# 1. 主题层级符合 spBv1.0/<group_id>/<msg_type>/<edge_node_id>/<device_id>
mosquitto_sub -t "spBv1.0/$GROUP_ID/+/+/+" -C 5 -W 10 | while read topic payload; do
  echo "topic=$topic"
  type=$(echo "$topic" | awk -F'/' '{print $3}')
  case "$type" in
    NBIRTH|NDEATH|DBIRTH|DDEATH|NDATA|DDATA|NCMD|DCMD) echo "VALID type=$type" ;;
    *) echo "INVALID type=$type"; exit 1 ;;
  esac
done
```

## T.12.5 失败处置预设

| 用例 | 常见失败模式 | 预设分类 | 处置入口 |
| ------ | -------------- | ---------- | ---------- |
| TC-BIZ-01~04 | 消费顺序/幂等断言失败 | T（用例断言） | 加固断言后回归 TEST-03 对应技术用例 |
| TC-BIZ-05~08 | ISO 报文解析异常或状态机不同步 | D（文档漂移）或 P（产品语义） | 按 TEST-05 双向修正流程处理 |
| TC-BIZ-09~12 | MQTT 连接抖动、JetStream 存储卷满 | E（环境） | hermes L1 清理后重跑，连续失败转 T/P |
| 全场景 | 夹具数据与用例期望不一致 | T（用例缺陷） | 更新夹具并同步 test-registry.tsv |

处置预设的目的【论证】：在用例设计阶段就给出"失败了往哪归类"的初判，避免运行时凭直觉定性；最终分类仍以 TEST-05 五问法为准。

## T.12.6 公共检查清单

- [ ] 夹具 `test-data-orders.json`、`docker-compose-test-env.yml` 已就绪且被 hermes 预检通过
- [ ] 每个 TC-BIZ 用例已标注环境 E1/E2/E3 与失败处置分类（P/T/E/D/B）
- [ ] Saga/冲正/补偿用例已验证"最终账务差额=0"
- [ ] ISO 20022 用例的报文夹具含 MsgId/EndToEndId/OriginalMsgId 等审计字段
- [ ] Sparkplug B 用例的主题命名空间与消息类型符合 [01-46](../../topics/01-基础概念与对比分析/01-46-IoT与互联网领域消息标准纵览.md) 规范
- [ ] 新加业务用例已在 TEST-08 覆盖矩阵中登记，并同步更新 TEST-09 任务包附录
- [ ] 业务场景用例的通过标准已量化（状态机终态、审计计数、差额、重复率）
- [ ] 跨系统场景已确认 topic/队列命名不冲突，且均带 `test.` 前缀
- [ ] 合成金融案例已在用例头部与正文中明确标注，避免被误读为真实机构测试
- [ ] 业务用例回归时同步跑一遍对应技术基线用例（TEST-03 TC-INT-03/04/07）

## T.12.7 参考来源

- 项目内：[TEST-02](../01-部署用例/TEST-02-运维部署测试用例.md)、[TEST-03](TEST-03-集成测试用例.md)、[TEST-04](../03-集群用例/TEST-04-集群测试验证.md)、[02-47](../../topics/02-场景驱动架构设计/02-47-企业集成模式与事务消息模式.md)、[01-41](../../topics/01-基础概念与对比分析/01-41-工作流编排系统与消息协同.md)、[01-45](../../topics/01-基础概念与对比分析/01-45-产业领域消息标准纵览.md)、[01-46](../../topics/01-基础概念与对比分析/01-46-IoT与互联网领域消息标准纵览.md)、[Testing/fixtures](../fixtures/)

- 外部：[ISO 20022 注册库](https://www.iso20022.org/)、[Sparkplug 规范](https://sparkplug.eclipse.org/specification/)、[EIP Saga 模式](https://www.enterpriseintegrationpatterns.com/patterns/conversation/Saga.html)

## T.12.8 通用业务场景契约库（L5 互链）

本文档三场景（电商订单/金融转账/IoT 遥测）的**契约视角**落在顶层 [Testing/06-契约语义测试/03-业务场景/](../../Testing/06-契约语义测试/03-业务场景/README.md)（批次74，TEST-15 规范）：

| 本文档场景 | 契约包 | 输入断言源 |
| ---- | ---- | ---- |
| 电商订单全链路 | [01-order-lifecycle](../../Testing/06-契约语义测试/03-业务场景/01-order-lifecycle/contract.yaml) | invariants（幂等/有序/状态机） |
| 金融转账 | [02-payment-reconciliation](../../Testing/06-契约语义测试/03-业务场景/02-payment-reconciliation/contract.yaml) | invariants（资损级幂等/证据指纹） |
| IoT 遥测 | [05-iot-telemetry](../../Testing/06-契约语义测试/03-业务场景/05-iot-telemetry/contract.yaml) | invariants（QoS 分级/stale 丢弃） |

用例执行以契约包 contract.yaml 的 invariants 为断言输入；契约变更经 contract-drift-check.sh 触发本文档用例 drift 重跑（见 [TEST-15](../../Testing/06-契约语义测试/00-模型与规划/TEST-C3-业务场景契约库与用例规范.md) §T.15.5）。

---

**最后更新**: 2026-11-18
