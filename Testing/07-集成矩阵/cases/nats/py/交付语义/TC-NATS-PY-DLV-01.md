# TC-NATS-PY-DLV-01：PY 客户端的 交付语义 断言

> **维度**：系统=NATS | 语言=PY | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- nats-py v2.17.0 JetStream 上下文

## When

- 生产 500+消费端中断重启

## Then

- 未确认消息重投
- pull 订阅游标不跨越 AckFloor

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/py/交付语义/TC-NATS-PY-DLV-01.sh   # 计划打印
```

## 关联

- 01-73 nats-py 核实版本
