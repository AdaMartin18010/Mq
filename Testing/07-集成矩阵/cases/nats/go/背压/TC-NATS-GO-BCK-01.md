# TC-NATS-GO-BCK-01：Go 客户端的 JetStream 背压平台期断言

> **维度**：系统=NATS | 语言=GO | 特性=BCK（背压） | 转换链=T3,T4
> **断言源**：ASE-010（maxAckPending=100 平台期，01-66 观测法）
> **环境**：E2 docker；**状态**：pending

## Given

- NATS JetStream（nats-server.conf.template JetStream 块）；stream `BPT` workqueue 保留
- Go pull consumer（nats.go v1.56.0）：`MaxAckPending=100`、`AckExplicit`，消费端**只消费不 ack**
- 生产者持续投递 500 条

## When

- 采样 `nats consumer info` 的 pending 数（10s 间隔 × 6 次）

## Then

- pending 平台期 = 100（±0，ASE-010 主断言）
- 消费进程 RSS 曲线平稳（无 OOM 增长趋势，01-66 §1.66.7 观测族）
- 生产者侧无 broker 报错（背压停推非拒绝）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/go/背压/TC-NATS-GO-BCK-01.sh
```

## 关联

- 语义矩阵：TEST-C2 背压格（NATS=●）
- 设计/落地：02-22 → 03-29；对照格：TC-RABBITMQ-GO-BCK-01（prefetch 对照）
- 动态系统：DYN-A1 积压方程的实测数据源（TEST-15）
