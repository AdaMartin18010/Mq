# T.07 可观测与自治能力测试用例

> **本文档定位**：可观测性与自治运维能力的可执行用例库——监测/告警/自动伸缩/自愈四类（TC-OBS-01~12）。设计论证见 02-49 与 01-33；落地操作见 03-63。

## 目录

- [T.07 可观测与自治能力测试用例](#t07-可观测与自治能力测试用例)
  - [目录](#目录)
  - [T.07.1 范围与策略](#t071-范围与策略)
  - [T.07.2 监测用例（TC-OBS-01~03）](#t072-监测用例tc-obs-0103)
  - [T.07.3 告警用例（TC-OBS-04~07）](#t073-告警用例tc-obs-0407)
  - [T.07.4 自动伸缩用例（TC-OBS-08）](#t074-自动伸缩用例tc-obs-08)
  - [T.07.5 自愈用例（TC-OBS-09~10）](#t075-自愈用例tc-obs-0910)
  - [T.07.6 质量与防退化用例（TC-OBS-11~12）](#t076-质量与防退化用例tc-obs-1112)
  - [T.07.7 检查清单](#t077-检查清单)
  - [T.07.8 与现有资产的联动](#t078-与现有资产的联动)
  - [T.07.9 与质量门禁的衔接](#t079-与质量门禁的衔接)

---

## T.07.1 范围与策略

四大能力域的测试目标：监测=看见的对（不缺信号、不丢数据）；告警=该响的响、不该响的不响；伸缩=量变及时且正确；自愈=质变处置有效且安全。与 TEST-01 五层金字塔的关系：本库主要落在 L4（集群/平台层）并消费 L3 的契约数据。

用例统一字段结构（与 TEST-02 相同）：目的 → 步骤（命令）→ 预期输出 → 通过标准 → 失败处置分类。执行记录模板：

```text
[TC-OBS-08] 日期/执行人/环境
注入: produce 10k msg/s × 300s
观测: 副本 2→18（+16）；扩容时延 2m41s；消费计数 3,000,000=3,000,000
结论: PASS（时延优于 5 分钟基线）
```

## T.07.2 监测用例（TC-OBS-01~03）

环境与数据规则：本库用例在 L4 层执行；指标检查基于 Prometheus API（无环境时 SKIP）；自治用例在独立命名空间/测试集群执行，禁止触达生产告警接收器。

**TC-OBS-01 指标体系完备性**:

- 目的：验证 01-33.2 六系统指标矩阵的行覆盖
- 逐系统抽查命令：

| 系统 | 流量信号抽查 | 语义信号抽查 |
| ------ | -------------- | -------------- |
| Kafka | `kafka_server_brokertopicmetrics_messagesin_total` | `kafka_consumergroup_lag` |
| Pulsar | `pulsar_rate_in` / `pulsar_throughput_in` | `pulsar_subscription_back_log` |
| RabbitMQ | `rabbitmq_queue_messages_published_total` | `rabbitmq_queue_messages_ready` |
| NATS | `gnatsd_varz_in_msgs` | `nats_jetstream_consumer_num_pending` |
| Redis | `redis_commands_processed_total` | `redis_stream_pending`（或 PEL 采集器） |
| MQTT | broker 连接/消息速率指标 | 会话堆积指标 |

- 通过标准：矩阵每行 ≥1 个非空序列；缺行记采集缺口并补 exporter 配置

**TC-OBS-02 指标时效性**:

- 步骤：对比 broker 实际产生消息速率与指标曲线延迟；注入已知速率（如固定 1k msg/s）比对曲线

```bash
# 记录注入时间与指标可见时间差
date +%s > /tmp/inject_ts
./topics/scripts/benchmark.sh kafka 60 1000
# 观察 Prometheus 曲线起点与 /tmp/inject_ts 的差值
```

- 通过标准：采集-展示延迟 < 2× scrape_interval【估算】；超期查 exporter 缓冲与网络

**TC-OBS-03 高基数防护**:

- 步骤：统计序列总量与 topic/queue 级指标数：

```bash
curl -s 'localhost:9090/api/v1/query?query=count(count%20by%20__name__)({__name__!=""})'
curl -s 'localhost:9090/api/v1/query?query=count(kafka_consumergroup_lag)'  # 组×分区级基数
```

- 通过标准：序列总量 < Prometheus 容量规划值【估算】；超限则启用 topk 聚合或丢弃标签

## T.07.3 告警用例（TC-OBS-04~07）

**TC-OBS-04 告警链路端到端**:

- 步骤：手工 fire 测试规则 → Alertmanager → 接收器：

```bash
amtool alert add alertname=TestP0 severity=p0 system=kafka --alertmanager.url=http://localhost:9093
# 或注入测试指标触发真实规则
echo 'kafka_controller_offlinepartitionscount 1' | curl --data-binary @- localhost:9090/api/v1/import/prometheus
```

- 通过标准：P0 到达电话/IM < 2 分钟；路由与 severity 标签一致

**TC-OBS-05 抑制与静默正确性**:

- 步骤：模拟父级故障（杀 broker）观察子级 topic 告警是否被抑制；设置带到期时间的静默：

```bash
amtool silence add system=kafka --duration=30m --alertmanager.url=http://localhost:9093 \
  --comment="planned-maintenance"
```

- 通过标准：抑制规则生效（不重复轰炸）；静默到期自动恢复；周检无超期静默

**TC-OBS-06 SLO 燃尽告警校准**:

- 注入方法对照表：

| 目标错误率 | 注入方式 | 预期 |
| ----------- | ---------- | ------ |
| 0.2%（>14.4×基线） | 客户端随机 nack 或故障注入 | 1h 窗口 Critical 触发 |
| 0.05%（<基线×6） | 微幅错误注入 | 不触发（防误报验证） |

- 步骤：注入可控错误率，验证多窗口 burn rate 规则按预期触发/不触发
- 通过标准：2% 预算/1h 注入在 1h 窗口内触发 Critical；0.1% 注入不触发【论证：多窗口设计语义】

**TC-OBS-07 告警质量周检**:

- 步骤：`./topics/scripts/alert-quality-check.sh --week`
- 通过标准：无 runbook 告警=0；静默超期=0；重复率（同根因多条）下降趋势

## T.07.4 自动伸缩用例（TC-OBS-08）

**TC-OBS-08 按 lag 扩缩容正确性**:

- 环境：KEDA + Kafka consumer（config-templates/keda-scaledobject-kafka.yaml）
- 步骤：

```bash
# ① 阶梯加压：produce 速率 1k→5k→10k msg/s（benchmark.sh）
./topics/scripts/benchmark.sh kafka 300 10000
# ② 观察：副本数随 lag 增长；记录扩容时延（lag 越阈→新副本 Ready）
kubectl get pods -w | grep orders-consumer
# ③ 撤压：观察缩容冷却期后回落到 minReplica
```

- 通过标准：扩容时延 < 5 分钟【估算】；无消息丢失（消费计数=生产计数）；缩容后 lag 不回升；扩容期间无 rebalance 风暴（重平衡次数 < 副本增量×2）

## T.07.5 自愈用例（TC-OBS-09~10）

**TC-OBS-09 自愈有效性（按 runbook 注入）**:

- 步骤对照 03-63.5 表逐行注入：

| 场景 | 注入命令 | 预期自动处置 |
| ------ | ---------- | -------------- |
| 进程消失 | `docker kill <broker>` | 平台拉起（restart） |
| 磁盘压力 | 填充数据盘至 80% | 清理机器人执行+告警 |
| consumer 卡死 | `kill -STOP 1`（pod 内） | liveness 超时重启 |
| leader 倾斜 | 手动干扰 leader 分布 | preferred election 恢复 |

```bash
# 例：consumer 卡死自愈
kubectl exec <consumer-pod> -- kill -STOP 1   # 模拟卡死（心跳在、无进展）
# 预期：liveness 探针超时后重启 pod；消费恢复；审计日志有记录
```

- 通过标准：每行场景的 检测→处置→恢复→留痕 四步完整；处置次数超过熔断阈值自动升级人工

**TC-OBS-10 护栏负向用例（不该自动的绝不自动）**:

- 步骤：模拟 quorum 丢失、DLQ 突增、疑似脑裂恢复三类场景
- 通过标准：**无任何自动处置动作**，仅告警到人；若发现自动动作 → 立即按 P 类缺陷修复并回滚自治配置（TEST-05 建档）

## T.07.6 质量与防退化用例（TC-OBS-11~12）

**TC-OBS-11 仪表板随发布回归**：Grafana 面板随 exporter/broker 升级检查指标名有效性（指标改名会静默断面板）：

```bash
# 导出全部面板使用的指标名，与 Prometheus 实际序列对账
curl -s localhost:9090/api/v1/label/__name__/values > /tmp/actual_metrics.json
# 面板数据源缺失时面板显示 No data——回归清单：近一季度变更过的 exporter 对应面板
```

**TC-OBS-12 告警阈值漂移检测**：季度对比各阈值的历史触发频率，触发率突变（>10×）的阈值进入复核定级【估算】；数据源：Alertmanager 历史 API 或告警台账。

## T.07.7 检查清单

- [ ] TC-OBS-01 六系统指标矩阵无缺行
- [ ] TC-OBS-04/06 告警链路与 SLO 规则校准通过
- [ ] TC-OBS-08 伸缩用例记录扩容时延实测值
- [ ] TC-OBS-09/10 自愈正反向用例均通过（正向有效+负向不动）
- [ ] 失败项按 TEST-05 建档；本用例库变更入版本评审

## T.07.8 与现有资产的联动

| 用例 | 复用资产 | 产出去向 |
| ------ | ---------- | ---------- |
| TC-OBS-01/02/03 | config-templates 告警规则、Grafana 面板 | 采集缺口清单 → 03-63 步骤回填 |
| TC-OBS-08 | keda-scaledobject-kafka.yaml、benchmark.sh | 扩容时延/正确性实测 → 02-49 阈值标定回写 |
| TC-OBS-09 | 03-63.5 runbook 表、chaos-test.sh | 演练记录 → GAME DAY 复盘（03-63） |
| TC-OBS-07 | alert-quality-check.sh | 周检报告 → 告警治理阈值调参 |

执行顺序建议：先 TC-OBS-01（看见）→ 04/06（判断）→ 08（量变）→ 09/10（质变）；全绿后再考虑提升自治级别（02-49 L1→L3）。

## T.07.9 与质量门禁的衔接

本库用例接入 TEST-01 T.01.5 门禁表：TC-OBS-04（告警链路）与 TC-OBS-08（伸缩正确性）纳入发布门禁；TC-OBS-01/07 纳入批次门禁（doc-self-check full 时核验 Grafana 面板数据源有效性清单是否随 exporter 升级更新）。执行失败按 TEST-05 五问分类——自治类故障优先定性 T/E（用例或环境），涉及自动处置伤害数据面的才定性 P。

---

**最后更新**: 2026-11-17
