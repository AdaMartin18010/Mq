# TC-SYN-MQTT-LAG-01：MQTT 桥接/会话滞后可观测 运维行为测试

> **维度**：系统=MQTT | 域=SYN（桥接/会话滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 MQTT 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 桥接链路 QoS1 持续发布

## When

- 桥接另一端消费落后

## Then

- bridge inflight / backlog 长度可采集
- 离线消息队列长度（persistence max_queued_messages）告警
- 告警阈值：inflight > 20 或 queued > 1000

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-MQTT-LAG-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 MQTT 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
