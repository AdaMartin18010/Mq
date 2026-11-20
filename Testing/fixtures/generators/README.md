# 测试数据工厂（fixtures/generators/）

> 批次 93。为 8 业务场景包生成配套测试数据（含边界值）。字段对齐 Testing/06-契约语义测试/03-业务场景/*/contract.yaml。
> 用法：`python3 gen-<domain>.py [N]`（默认 100 条，JSONL 输出到 stdout）；`python3 gen-<domain>.py --validate` 自检边界值覆盖。

## 生成器清单

| 生成器 | 场景包 | 边界值覆盖 |
| ---- | ---- | ---- |
| gen-orders.py | 01-order-lifecycle | 空明细/零金额/超长订单号/Unicode 商品名 |
| gen-payments.py | 02-payment-reconciliation | 零金额/负金额（非法）/极大金额/全币种 |
| gen-iot-telemetry.py | 05-iot-telemetry | 传感器极值/时间戳漂移/乱序到达 |
| gen-inventory.py | 03-inventory | 空幂等键/空 SKU/零数量/极大数量/TTL=0 即时过期/Unicode 商品名 |
| gen-notification.py | 04-notification | 空通知 ID/空通道数组/全通道 fan-out/空内容引用/空幂等键 |
| gen-cdc-sync.py | 06-cdc-sync | op=create/delete before/after=null 镜像/op=read 快照/空对象 update/tsMs=0 |
| gen-audit-trail.py | 07-audit-trail | 空操作者/空操作类型/空对象引用/Unicode 操作者/超长引用 + 链式完整性校验 |
| gen-task-queue.py | 08-task-queue | 空任务 ID/重试额度=0/负额度（非法）/截止已过/空任务类型/Unicode 类型 |

> 批次187：金样本 3 组 → 8 组（与 03-业务场景 01~08 全对齐；xlang-matrix.sh --validate 循环同步扩至 8 生成器）。

数据格式：JSONL（每行一条消息，含 trace-id/idempotency-key 头域内嵌 `_headers` 键），可直接管道给 producer 脚本或 fixtures compose 内的客户端容器。

**最后更新**: 2026-11-21（批次187：金样本 8 场景全对齐）
