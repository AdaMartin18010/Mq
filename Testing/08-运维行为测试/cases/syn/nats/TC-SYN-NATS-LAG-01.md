# TC-SYN-NATS-LAG-01：NATS 复制滞后可观测 运维行为测试

> **维度**：系统=NATS | 域=SYN（复制滞后可观测）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JetStream R3 stream 持续发布

## When

- 副本同步落后

## Then

- stream state sequence diff / consumer ack pending 可观测
- nats-server route latency / JetStream  advisories 采集
- 告警阈值：leader 与 replica sequence diff > 100

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/nats/TC-SYN-NATS-LAG-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 NATS 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
