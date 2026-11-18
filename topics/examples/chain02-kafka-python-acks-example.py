# 链#2（01-82）：Kafka acks/ISR → aiokafka/confluent-kafka → broker 配置 映射示例
# 对应矩阵用例：TC-KAFKA-PY-DLV-01（ASE-001 主断言的客户端侧）
# 部署映射: min.insync.replicas=2（kafka-server.properties.template）

from aiokafka import AIOKafkaProducer
import asyncio

async def main():
    producer = AIOKafkaProducer(
        bootstrap_servers="localhost:19092",
        acks="all",                    # 交付语义格 Kafka=● 的客户端前提
        enable_idempotence=True,       # 幂等去重格=●（PID+序列号，01-63）
        max_in_flight_requests_per_connection=5,
    )
    await producer.start()
    try:
        # delivery.timeout.ms 默认 120s（重试退避格 Kafka=◐ 依据：有超时无退避）
        await producer.send_and_wait("orders.events", b'{"orderId":"ORD-1"}')
    finally:
        await producer.stop()

asyncio.run(main())

# 对账点：acks=all 且 broker min.insync.replicas=2 → 已确认消息不丢（ASE-001）
