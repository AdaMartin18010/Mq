"""
NATS Client示例代码 (Python)

功能：演示NATS客户端的基本用法和最佳实践
参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
依赖：pip install nats-py
"""

import asyncio
import logging
from nats.aio.client import Client as NATS
from nats.aio.errors import ErrConnectionClosed, ErrTimeout

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class NATSClientExample:
    def __init__(self, servers=['nats://localhost:4222']):
        self.nc = NATS()
        self.servers = servers
    
    async def connect(self):
        """连接到NATS服务器"""
        try:
            await self.nc.connect(
                servers=self.servers,
                reconnect_time_wait=1,  # 重连等待时间
                max_reconnect_attempts=-1,  # 无限重连
                name='python-example-client',
            )
            logger.info("NATS连接成功")
        except Exception as e:
            logger.error(f"NATS连接失败: {e}")
            raise
    
    async def publish_subscribe(self):
        """发布-订阅模式（参考：01-05-程序设计模式分析）"""
        subject = "events.user.created"
        
        # 订阅消息
        async def message_handler(msg):
            logger.info(f"收到消息: subject={msg.subject}, data={msg.data.decode()}")
            # 处理消息逻辑
            await self.process_message(msg)
        
        sub = await self.nc.subscribe(subject, cb=message_handler)
        logger.info(f"已订阅主题: {subject}")
        
        # 发布消息
        await self.nc.publish(subject, b"user created: 12345")
        logger.info(f"已发布消息到主题: {subject}")
        
        # 等待消息处理
        await asyncio.sleep(1)
        
        # 取消订阅
        await sub.unsubscribe()
    
    async def request_reply(self):
        """请求-响应模式（参考：02-03-程序设计模式场景化应用）"""
        subject = "service.echo"
        
        # 订阅请求
        async def request_handler(msg):
            response = f"Echo: {msg.data.decode()}"
            await msg.respond(response.encode())
            logger.info(f"处理请求: {msg.data.decode()}, 响应: {response}")
        
        await self.nc.subscribe(subject, cb=request_handler)
        logger.info(f"已订阅请求主题: {subject}")
        
        # 发送请求
        try:
            response = await self.nc.request(subject, b"hello", timeout=1)
            logger.info(f"收到响应: {response.data.decode()}")
        except ErrTimeout:
            logger.error("请求超时")
    
    async def queue_group(self):
        """队列组模式（负载均衡）"""
        subject = "tasks.process"
        queue_group = "worker-group"
        
        # 多个Consumer订阅同一Subject，消息只投递给一个Consumer
        async def task_handler(msg):
            logger.info(f"处理任务: {msg.data.decode()}")
            # 处理任务逻辑
            await self.process_task(msg)
        
        await self.nc.subscribe(subject, queue=queue_group, cb=task_handler)
        logger.info(f"已加入队列组: {queue_group}, 主题: {subject}")
        
        # 发布任务
        for i in range(5):
            await self.nc.publish(subject, f"task-{i}".encode())
        
        await asyncio.sleep(1)
    
    async def jetstream_example(self):
        """JetStream持久化示例"""
        js = self.nc.jetstream()
        
        # 创建Stream
        stream_name = "ORDERS"
        await js.add_stream(
            name=stream_name,
            subjects=["orders.>"],
            max_age=3600,  # 1小时
            max_bytes=1024 * 1024 * 100,  # 100MB
        )
        logger.info(f"已创建Stream: {stream_name}")
        
        # 发布消息到Stream
        await js.publish("orders.new", b"order-123")
        logger.info("已发布消息到Stream")
        
        # 创建Consumer并消费消息
        async def msg_handler(msg):
            logger.info(f"收到Stream消息: {msg.data.decode()}")
            await msg.ack()
        
        await js.subscribe("orders.>", cb=msg_handler)
        await asyncio.sleep(1)
    
    async def process_message(self, msg):
        """处理消息"""
        # 业务逻辑处理
        pass
    
    async def process_task(self, msg):
        """处理任务"""
        # 任务处理逻辑
        pass
    
    async def close(self):
        """关闭连接"""
        await self.nc.close()


async def main():
    """主函数"""
    client = NATSClientExample(['nats://localhost:4222'])
    
    try:
        # 连接
        await client.connect()
        
        # 发布-订阅模式
        await client.publish_subscribe()
        
        # 请求-响应模式
        await client.request_reply()
        
        # 队列组模式
        await client.queue_group()
        
        # JetStream示例
        await client.jetstream_example()
        
    except Exception as e:
        logger.error(f"异常: {e}")
    finally:
        await client.close()


if __name__ == '__main__':
    asyncio.run(main())
