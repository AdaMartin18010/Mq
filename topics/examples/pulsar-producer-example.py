#!/usr/bin/env python3
"""
Pulsar Producer示例

功能：
- 创建Producer并发送消息
- 支持同步和异步发送
- 支持批量发送
"""

import pulsar
from pulsar import MessageId

# 配置
SERVICE_URL = "pulsar://localhost:6650"
TOPIC = "persistent://public/default/my-topic"

def main():
    # 创建Pulsar客户端
    client = pulsar.Client(SERVICE_URL)
    
    try:
        # 创建Producer
        producer = client.create_producer(
            topic=TOPIC,
            producer_name="my-producer",
            batching_enabled=True,
            batching_max_messages=100,
            batching_max_publish_delay_ms=10
        )
        
        # 同步发送消息
        msg_id = producer.send("Hello Pulsar".encode('utf-8'))
        print(f"Message sent: {msg_id}")
        
        # 异步发送消息
        producer.send_async(
            "Hello Pulsar Async".encode('utf-8'),
            callback=lambda res, msg_id: print(f"Message sent async: {msg_id}")
        )
        
        # 发送带属性的消息
        producer.send(
            "Hello Pulsar with Properties".encode('utf-8'),
            properties={'property1': 'value1'},
            partition_key='my-key'
        )
        
        # 发送多条消息
        for i in range(10):
            producer.send(f"Message {i}".encode('utf-8'))
        
        # 关闭Producer
        producer.close()
    finally:
        # 关闭客户端
        client.close()

if __name__ == "__main__":
    main()
