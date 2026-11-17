"""
AsyncAPI 生成风格示例（Python）——订单事件生产者
说明: 消息模型为 Modelina 风格生成物（由 asyncapi-kafka-example.yaml 的
schema 生成），横切逻辑（重试/死信/幂等，见 02-16/02-17/02-25）为手工补充，
生成代码不自带这些能力（见 01-32.2 生成质量边界）。
"""
import json
import time
import uuid
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone

from kafka import KafkaProducer


# ---- Modelina 风格生成的数据模型（生成物起点，勿手工改字段语义） ----
@dataclass
class OrderCreatedEvent:
    orderId: str
    amount: float
    occurredAt: str
    currency: str = "CNY"


# ---- 手工补充：应用层封装（生成物之外的能力） ----
class OrderEventProducer:
    """订单事件生产者：封装追踪头、幂等键与失败转移。"""

    def __init__(self, bootstrap_servers: str):
        self._producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            acks="all",                 # 03-16 基线
            retries=3,                # 02-16 重试（上限结合业务时效）
            enable_idempotence=True,  # 02-25 生产者幂等
            value_serializer=lambda v: json.dumps(v).encode(),
            key_serializer=lambda k: k.encode() if k else None,
        )

    def publish_order_created(self, order_id: str, amount: float) -> None:
        event = OrderCreatedEvent(
            orderId=order_id,
            amount=amount,
            occurredAt=datetime.now(timezone.utc).isoformat(),
        )
        headers = [
            ("trace-id", str(uuid.uuid4()).encode()),      # 02-23 追踪
            ("idempotency-key", order_id.encode()),        # 02-25 幂等键
        ]
        future = self._producer.send(
            "orders.order.created",
            key=order_id,
            value=asdict(event),
            headers=headers,
        )
        try:
            future.get(timeout=10)
        except Exception as exc:  # 最终失败 → 转死信 topic（02-17）
            self._producer.send(
                "orders.order.dlq",
                key=order_id,
                value=asdict(event),
                headers=headers + [("failure-reason", str(exc).encode()[:255])],
            )
            raise

    def flush(self) -> None:
        self._producer.flush()


if __name__ == "__main__":
    producer = OrderEventProducer("localhost:9092")
    producer.publish_order_created(order_id="ORD-20261117-001", amount=199.0)
    producer.flush()
    print("published + flushed")
