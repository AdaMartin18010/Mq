#!/usr/bin/env python3
"""
RabbitMQ Producer示例
演示如何使用pika库发送消息到RabbitMQ
"""

import pika
import json
import time

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

def send_message():
    """发送消息示例"""
    connection = create_connection()
    channel = connection.channel()
    
    # 声明Exchange（Direct类型）
    channel.exchange_declare(
        exchange='order_exchange',
        exchange_type='direct',
        durable=True
    )
    
    # 声明队列
    channel.queue_declare(
        queue='order_queue',
        durable=True
    )
    
    # 绑定队列到Exchange
    channel.queue_bind(
        exchange='order_exchange',
        queue='order_queue',
        routing_key='order.created'
    )
    
    # 发送消息
    for i in range(10):
        message = {
            'order_id': f'ORD-{i:04d}',
            'user_id': f'USER-{i}',
            'amount': 100.0 + i,
            'timestamp': time.time()
        }
        
        channel.basic_publish(
            exchange='order_exchange',
            routing_key='order.created',
            body=json.dumps(message),
            properties=pika.BasicProperties(
                delivery_mode=2,  # 持久化消息
                content_type='application/json'
            )
        )
        print(f"Sent: {message['order_id']}")
    
    connection.close()
    print("Messages sent successfully")

if __name__ == '__main__':
    send_message()
