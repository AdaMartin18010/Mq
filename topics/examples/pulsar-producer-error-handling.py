#!/usr/bin/env python3
"""
Pulsar Python Producer容错异常处理示例
基于concept06.md和Pulsar官方文档
"""

import pulsar
import logging
import time
from typing import Optional
from functools import wraps
from pulsar import MessageId

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 配置
SERVICE_URL = "pulsar://localhost:6650"
TOPIC = "persistent://public/default/my-topic"
MAX_RETRIES = 3
INITIAL_DELAY_MS = 1000


def retry_on_failure(max_retries=3, initial_delay=1):
    """重试装饰器"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except (pulsar.Timeout, pulsar.NotConnectedError) as e:
                    if attempt < max_retries - 1:
                        delay = initial_delay * (2 ** attempt)
                        logger.warning(f"Retry {attempt+1}/{max_retries} after {delay}s: {e}")
                        time.sleep(delay)
                    else:
                        logger.error(f"Max retries reached: {e}")
                        raise
                except Exception as e:
                    logger.error(f"Non-retriable error: {e}")
                    raise
            return None
        return wrapper
    return decorator


class RobustPulsarProducer:
    """带容错机制的Pulsar Producer"""
    
    def __init__(self, service_url: str, topic: str):
        self.service_url = service_url
        self.topic = topic
        self.client: Optional[pulsar.Client] = None
        self.producer: Optional[pulsar.Producer] = None
        self.max_retries = MAX_RETRIES
        self.initial_delay_ms = INITIAL_DELAY_MS

    def initialize(self):
        """初始化Producer"""
        try:
            self.client = pulsar.Client(
                self.service_url,
                connection_timeout_ms=10000,  # 连接超时10秒
                operation_timeout_seconds=30   # 操作超时30秒
            )
            
            self.producer = self.client.create_producer(
                self.topic,
                send_timeout_millis=30000,      # 发送超时30秒
                max_pending_messages=1000,      # 最大待发送消息数
                block_if_queue_full=True,       # 队列满时阻塞
                batching_enabled=True,          # 启用批量发送
                batching_max_publish_delay_ms=10
            )
            logger.info("Producer initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize producer: {e}")
            raise

    @retry_on_failure(max_retries=3)
    def send_with_retry(self, message: bytes) -> Optional[MessageId]:
        """带重试的消息发送"""
        for attempt in range(self.max_retries):
            try:
                msg_id = self.producer.send(message)
                logger.info(f"Message sent successfully: {msg_id}")
                return msg_id
            except pulsar.Timeout as e:
                logger.warning(f"Send timeout (attempt {attempt + 1}/{self.max_retries}): {e}")
                if attempt < self.max_retries - 1:
                    time.sleep(self.initial_delay_ms * (2 ** attempt) / 1000)  # 指数退避
                else:
                    logger.error("Max retries reached, message send failed")
                    raise
            except pulsar.ProducerQueueIsFullError as e:
                logger.error(f"Producer queue is full: {e}")
                # 队列满，等待后重试
                time.sleep(1)
                continue
            except pulsar.SchemaSerializationException as e:
                logger.error(f"Schema serialization failed: {e}")
                # Schema错误不可重试
                raise
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
                if attempt < self.max_retries - 1:
                    time.sleep(self.initial_delay_ms * (2 ** attempt) / 1000)
                else:
                    raise

        return None

    def send_async_with_callback(self, message: bytes, callback=None):
        """异步发送带回调"""
        def default_callback(res, msg_id):
            if res != pulsar.Result.Ok:
                logger.error(f"Async send failed: {res}")
                # 可以在这里实现重试逻辑
            else:
                logger.info(f"Async send succeeded: {msg_id}")
            if callback:
                callback(res, msg_id)

        self.producer.send_async(message, callback=default_callback)

    def close(self):
        """关闭Producer和Client"""
        try:
            if self.producer:
                self.producer.close()
            if self.client:
                self.client.close()
        except Exception as e:
            logger.error(f"Error closing producer: {e}")


class RobustPulsarConsumer:
    """带容错机制的Pulsar Consumer"""
    
    def __init__(self, service_url: str, topic: str, subscription_name: str):
        self.service_url = service_url
        self.topic = topic
        self.subscription_name = subscription_name
        self.client: Optional[pulsar.Client] = None
        self.consumer: Optional[pulsar.Consumer] = None
        self.dlq_producer: Optional[pulsar.Producer] = None

    def initialize(self):
        """初始化Consumer"""
        try:
            self.client = pulsar.Client(
                self.service_url,
                connection_timeout_ms=10000,
                operation_timeout_seconds=30
            )
            
            self.consumer = self.client.subscribe(
                self.topic,
                self.subscription_name,
                consumer_type=pulsar.ConsumerType.Shared,
                initial_position=pulsar.InitialPosition.Latest,
                ack_timeout_millis=30000,
                negative_ack_redelivery_delay_ms=60000,
                receiver_queue_size=1000
            )
            
            # 创建死信队列Producer
            self.dlq_producer = self.client.create_producer(f"{self.topic}-dlq")
            
            logger.info("Consumer initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize consumer: {e}")
            raise

    def consume_with_error_handling(self):
        """带异常处理的消息消费"""
        while True:
            try:
                msg = self.consumer.receive(timeout_millis=1000)
                
                try:
                    # 处理消息
                    self.process_message(msg)
                    
                    # 确认消息
                    self.consumer.acknowledge(msg)
                except ProcessingError as e:
                    # 处理失败，否定确认（自动重试）
                    logger.error(f"Failed to process message: {e}")
                    self.consumer.negative_acknowledge(msg)
                except FatalError as e:
                    # 致命错误，确认消息（跳过）
                    logger.error(f"Fatal error processing message: {e}")
                    self.consumer.acknowledge(msg)
                    # 发送到死信队列
                    self.send_to_dlq(msg, e)

            except pulsar.Timeout:
                # 接收超时，继续
                continue
            except pulsar.AlreadyClosedError:
                # Consumer已关闭
                logger.info("Consumer closed")
                break
            except pulsar.NotConnectedError as e:
                # 连接断开，等待自动重连
                logger.warning(f"Not connected: {e}, waiting for reconnect...")
                continue
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
                # 记录错误但继续运行

    def process_message(self, msg):
        """处理消息"""
        # 业务逻辑
        content = msg.data()
        logger.info(f"Processing message: {content}")
        # ... 处理逻辑

    def send_to_dlq(self, msg, error):
        """发送到死信队列"""
        try:
            dlq_msg = msg.data()
            self.dlq_producer.send(
                dlq_msg,
                properties={
                    'original_topic': msg.topic_name(),
                    'original_msg_id': str(msg.message_id()),
                    'error': str(error),
                }
            )
            logger.info(f"Message sent to DLQ: {msg.message_id()}")
        except Exception as e:
            logger.error(f"Failed to send to DLQ: {e}")

    def close(self):
        """关闭Consumer和Client"""
        try:
            if self.dlq_producer:
                self.dlq_producer.close()
            if self.consumer:
                self.consumer.close()
            if self.client:
                self.client.close()
        except Exception as e:
            logger.error(f"Error closing consumer: {e}")


class ProcessingError(Exception):
    """处理错误（可重试）"""
    pass


class FatalError(Exception):
    """致命错误（不可重试）"""
    pass


def main():
    """主函数"""
    # Producer示例
    producer = RobustPulsarProducer(SERVICE_URL, TOPIC)
    producer.initialize()
    
    try:
        # 同步发送带重试
        msg_id = producer.send_with_retry(b"Hello Pulsar")
        logger.info(f"Sent message: {msg_id}")
        
        # 异步发送带回调
        producer.send_async_with_callback(
            b"Hello Pulsar Async",
            callback=lambda res, msg_id: logger.info(f"Callback: {res}, {msg_id}")
        )
        
        time.sleep(2)
    finally:
        producer.close()
    
    # Consumer示例
    consumer = RobustPulsarConsumer(SERVICE_URL, TOPIC, "my-subscription")
    consumer.initialize()
    
    try:
        consumer.consume_with_error_handling()
    finally:
        consumer.close()


if __name__ == "__main__":
    main()
