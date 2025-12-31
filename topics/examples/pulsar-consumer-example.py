#!/usr/bin/env python3
"""
Pulsar Consumer示例

功能：
- 创建Consumer并消费消息
- 支持多种订阅模式（Exclusive/Shared/Failover/Key_Shared）
- 支持消息确认
"""

import pulsar
from pulsar import ConsumerType

# 配置
SERVICE_URL = "pulsar://localhost:6650"
TOPIC = "persistent://public/default/my-topic"
SUBSCRIPTION_NAME = "my-subscription"

def main():
    # 创建Pulsar客户端
    client = pulsar.Client(SERVICE_URL)
    
    try:
        # 创建Consumer（Shared订阅模式）
        consumer = client.subscribe(
            topic=TOPIC,
            subscription_name=SUBSCRIPTION_NAME,
            consumer_type=ConsumerType.Shared,
            ack_timeout_millis=30000
        )
        
        # 接收消息
        while True:
            try:
                # 接收消息（超时时间30秒）
                msg = consumer.receive(timeout_millis=30000)
                
                # 处理消息
                content = msg.data().decode('utf-8')
                print(f"Received message: {content}")
                print(f"Message ID: {msg.message_id()}")
                print(f"Message Key: {msg.partition_key()}")
                print(f"Properties: {msg.properties()}")
                
                # 确认消息
                consumer.acknowledge(msg)
            except Exception as e:
                print(f"Error processing message: {e}")
                # 否定确认
                consumer.negative_acknowledge(msg)
    finally:
        # 关闭Consumer和客户端
        consumer.close()
        client.close()

def consume_with_listener():
    """使用消息监听器消费消息"""
    client = pulsar.Client(SERVICE_URL)
    
    def process_message(consumer, msg):
        try:
            content = msg.data().decode('utf-8')
            print(f"Received: {content}")
            consumer.acknowledge(msg)
        except Exception as e:
            print(f"Error: {e}")
            consumer.negative_acknowledge(msg)
    
    try:
        consumer = client.subscribe(
            topic=TOPIC,
            subscription_name=SUBSCRIPTION_NAME,
            consumer_type=ConsumerType.Shared,
            message_listener=process_message
        )
        
        # 保持运行
        import time
        time.sleep(60)
        
        consumer.close()
    finally:
        client.close()

if __name__ == "__main__":
    main()
