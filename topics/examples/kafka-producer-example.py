"""
Kafka Producer示例代码 (Python)

功能：演示Kafka Producer的基本用法和最佳实践
参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
依赖：pip install kafka-python
"""

from kafka import KafkaProducer
from kafka.errors import KafkaError
import json
import logging
import time

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class KafkaProducerExample:
    def __init__(self, bootstrap_servers='localhost:9092'):
        # 创建Producer配置
        self.producer = KafkaProducer(
            bootstrap_servers=[bootstrap_servers],
            # 可靠性配置（参考：01-04-形式化证明框架）
            acks='all',  # 等待所有ISR副本确认
            retries=3,  # 重试次数
            max_in_flight_requests_per_connection=5,
            enable_idempotence=True,  # 启用幂等性
            
            # 性能优化配置（参考：01-06-架构设计深度分析）
            batch_size=16384,  # 16KB批量大小
            linger_ms=10,  # 等待10ms批量发送
            compression_type='snappy',  # 压缩算法
            
            # 序列化配置
            key_serializer=lambda k: k.encode('utf-8') if k else None,
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            
            # 其他配置
            request_timeout_ms=30000,
            delivery_timeout_ms=120000,
        )
    
    def send_message(self, topic, key=None, value=None):
        """发送消息"""
        try:
            # 同步发送
            future = self.producer.send(
                topic,
                key=key,
                value=value,
                partition=None  # 使用默认分区策略
            )
            
            # 获取结果（阻塞等待）
            record_metadata = future.get(timeout=10)
            logger.info(
                f"消息发送成功: topic={record_metadata.topic}, "
                f"partition={record_metadata.partition}, "
                f"offset={record_metadata.offset}"
            )
            return record_metadata
            
        except KafkaError as e:
            logger.error(f"发送消息失败: {e}")
            raise
    
    def send_message_async(self, topic, key=None, value=None, callback=None):
        """异步发送消息"""
        def on_send_success(record_metadata):
            logger.info(
                f"消息发送成功: topic={record_metadata.topic}, "
                f"partition={record_metadata.partition}, "
                f"offset={record_metadata.offset}"
            )
            if callback:
                callback(True, record_metadata)
        
        def on_send_error(exception):
            logger.error(f"发送消息失败: {exception}")
            if callback:
                callback(False, exception)
        
        try:
            future = self.producer.send(topic, key=key, value=value)
            future.add_callback(on_send_success)
            future.add_errback(on_send_error)
            
        except Exception as e:
            logger.error(f"发送消息异常: {e}")
            if callback:
                callback(False, e)
    
    def send_batch(self, topic, messages):
        """批量发送消息"""
        futures = []
        for key, value in messages:
            future = self.producer.send(topic, key=key, value=value)
            futures.append(future)
        
        # 等待所有消息发送完成
        for future in futures:
            try:
                record_metadata = future.get(timeout=10)
                logger.info(f"批量消息发送成功: offset={record_metadata.offset}")
            except KafkaError as e:
                logger.error(f"批量消息发送失败: {e}")
    
    def flush(self):
        """刷新缓冲区，确保所有消息都已发送"""
        self.producer.flush()
    
    def close(self):
        """关闭Producer"""
        self.producer.close()


def main():
    """主函数"""
    producer = KafkaProducerExample('localhost:9092')
    
    try:
        # 发送单条消息
        producer.send_message(
            topic='test-topic',
            key='user-123',
            value={'action': 'login', 'timestamp': time.time()}
        )
        
        # 异步发送消息
        producer.send_message_async(
            topic='test-topic',
            key='user-456',
            value={'action': 'logout', 'timestamp': time.time()},
            callback=lambda success, result: print(f"回调结果: {success}")
        )
        
        # 批量发送消息
        messages = [
            (f'key-{i}', {'id': i, 'data': f'message-{i}'})
            for i in range(10)
        ]
        producer.send_batch('test-topic', messages)
        
        # 刷新缓冲区
        producer.flush()
        
    finally:
        producer.close()


if __name__ == '__main__':
    main()
