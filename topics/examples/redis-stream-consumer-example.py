#!/usr/bin/env python3
"""
Redis Stream Consumer示例
演示如何使用redis-py库从Redis Stream消费消息
"""

import redis
import json

# Redis连接配置
REDIS_HOST = 'localhost'
REDIS_PORT = 6379
REDIS_DB = 0

def create_redis_client():
    """创建Redis客户端"""
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        db=REDIS_DB,
        decode_responses=True
    )

def consume_messages():
    """消费消息"""
    client = create_redis_client()
    stream_name = 'events:orders'
    group_name = 'order_processors'
    consumer_name = 'consumer-1'
    
    # 创建消费者组（如果不存在）
    try:
        client.xgroup_create(stream_name, group_name, id='0', mkstream=True)
    except redis.ResponseError:
        pass  # 组已存在
    
    # 消费消息
    while True:
        messages = client.xreadgroup(
            group_name,
            consumer_name,
            {stream_name: '>'},  # 读取未确认的消息
            count=10,
            block=1000  # 阻塞1秒
        )
        
        for stream, msgs in messages:
            for msg_id, data in msgs:
                print(f"Received: {msg_id} - {data}")
                
                # 处理消息
                # process_order(data)
                
                # 确认消息
                client.xack(stream_name, group_name, msg_id)

if __name__ == '__main__':
    try:
        consume_messages()
    except KeyboardInterrupt:
        print("Consumer stopped")
