#!/usr/bin/env python3
"""
Redis Stream Producer示例
演示如何使用redis-py库发送消息到Redis Stream
"""

import redis
import json
import time

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

def send_message():
    """发送消息到Redis Stream"""
    client = create_redis_client()
    stream_name = 'events:orders'
    
    for i in range(10):
        message = {
            'order_id': f'ORD-{i:04d}',
            'user_id': f'USER-{i}',
            'amount': 100.0 + i,
            'timestamp': time.time()
        }
        
        # 添加消息到Stream
        message_id = client.xadd(
            stream_name,
            message,
            maxlen=10000  # 最大长度10000
        )
        print(f"Sent: {message_id} - {message['order_id']}")
    
    print("Messages sent successfully")

if __name__ == '__main__':
    send_message()
