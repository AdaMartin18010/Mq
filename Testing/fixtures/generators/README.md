# 测试数据工厂（fixtures/generators/）

> 批次 93。为 8 业务场景包生成配套测试数据（含边界值）。字段对齐 契约语义测试/03-业务场景/*/contract.yaml。
> 用法：`python3 gen-<domain>.py [N]`（默认 100 条，JSONL 输出到 stdout）；`python3 gen-<domain>.py --validate` 自检边界值覆盖。

## 生成器清单

| 生成器 | 场景包 | 边界值覆盖 |
| ---- | ---- | ---- |
| gen-orders.py | 01-order-lifecycle | 空明细/零金额/超长订单号/Unicode 商品名 |
| gen-payments.py | 02-payment-reconciliation | 零金额/负金额（非法）/极大金额/全币种 |
| gen-iot-telemetry.py | 05-iot-telemetry | 传感器极值/时间戳漂移/乱序到达 |

数据格式：JSONL（每行一条消息，含 trace-id/idempotency-key 头域内嵌 `_headers` 键），可直接管道给 producer 脚本或 fixtures compose 内的客户端容器。

**最后更新**: 2026-11-18
