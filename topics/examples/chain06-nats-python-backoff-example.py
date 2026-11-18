# 链#6（01-82）：x-jetstream.backoff → nats-py 管理 API → consumer 配置 映射示例
# 对应矩阵用例：TC-NATS-PY-RET-01（ASE-006 退避序列断言）
# 绑定声明: x-jetstream: {maxDeliver: 5, backoff: [1s,5s,30s,2m,10m]}（08-task-queue 场景契约段）

import asyncio
import nats

async def main():
    nc = await nats.connect("localhost:4222")
    js = nc.jetstream()

    # 管理 API 建 durable：退避序列为声明式进契约（02-60：退避策略变更是契约级变更）
    await js.add_consumer(
        "TASKS",
        durable_name="task-workers-durable",
        max_deliver=5,                    # == x-jetstream.maxDeliver
        backoff=[1, 5, 30, 120, 600],     # 秒；== x-jetstream.backoff 序列
        ack_policy="explicit",            # == x-jetstream.ackPolicy
        max_ack_pending=100,              # == x-jetstream.maxAckPending
    )
    # 对账点：管理 API 回读 consumer info 可校验 delivery count（01-66 观测）
    await nc.close()

asyncio.run(main())
