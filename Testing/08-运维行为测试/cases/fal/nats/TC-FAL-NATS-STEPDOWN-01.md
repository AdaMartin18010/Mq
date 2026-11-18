# TC-FAL-NATS-STEPDOWN-01：NATS JetStream R3 stream leader stepdown 运维行为测试

> **维度**：系统=NATS | 域=FAL（JetStream R3 stream leader stepdown）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照 / §1.63.1 交付语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- JetStream R3 stream，使用 nats-cli 发起 stream cluster step-down

## When
- RTO 计时

## Then
- 新 leader 在 5s 内产生，stream info 中 leader 名称更新
- 已 ack 消息的 stream sequence 连续
- 脑裂防护：R3 Raft 多数派；分区 minority 副本不可写
- 数据一致性：消费者 ack 状态与消息序列在新 leader 上一致

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/nats/TC-FAL-NATS-STEPDOWN-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 §1.63.7 NATS 语义对照 / §1.63.1 交付语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
