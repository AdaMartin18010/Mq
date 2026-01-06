#!/usr/bin/env python3
"""
RabbitMQ Consumer示例
演示如何使用pika库从RabbitMQ消费消息
"""

import pika
import json

# 连接配置
RABBITMQ_HOST = 'localhost'
RABBITMQ_PORT = 5672
RABBITMQ_USER = 'guest'
RABBITMQ_PASSWORD = 'guest'

def create_connection():
    """创建RabbitMQ连接"""
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASSWORD)
    parameters = pika.ConnectionParameters(
        host=RABBITMQ_HOST,
        port=RABBITMQ_PORT,
        credentials=credentials
    )
    return pika.BlockingConnection(parameters)

def process_message(ch, method, properties, body):
    """处理消息的回调函数"""
    try:
        message = json.loads(body)
        print(f"Received: {message}")
        
        # 处理消息逻辑
        # process_order(message)
        
        # 手动确认消息
        ch.basic_ack(delivery_tag=method.delivery_tag)
    except Exception as e:
        print(f"Error processing message: {e}")
        # 拒绝消息，重新入队
        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=True)

def consume_messages():
    """消费消息"""
    connection = create_connection()
    channel = connection.channel()
    
    # 声明队列
    channel.queue_declare(
        queue='order_queue',
        durable=True
    )
    
    # 设置预取数量（公平分发）
    channel.basic_qos(prefetch_count=1)
    
    # 开始消费
    channel.basic_consume(
        queue='order_queue',
        on_message_callback=process_message
    )
    
    print("Waiting for messages. To exit press CTRL+C")
    channel.start_consuming()

if __name__ == '__main__':
    try:
        consume_messages()
    except KeyboardInterrupt:
        print("Consumer stopped")
