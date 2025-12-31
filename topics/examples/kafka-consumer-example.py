"""
Kafka Consumer示例代码 (Python)

功能：演示Kafka Consumer的基本用法和最佳实践
参考：[01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
依赖：pip install kafka-python
"""

from kafka import KafkaConsumer
from kafka.errors import KafkaError
import json
import logging
from typing import Dict, Any

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class KafkaConsumerExample:
    def __init__(self, bootstrap_servers='localhost:9092', group_id='test-group'):
        # 创建Consumer配置
        self.consumer = KafkaConsumer(
            bootstrap_servers=[bootstrap_servers],
            group_id=group_id,
            
            # 消费配置（参考：01-04-形式化证明框架）
            enable_auto_commit=False,  # 手动提交offset
            auto_offset_reset='earliest',  # 从最早的消息开始消费
            
            # 性能优化配置（参考：01-06-架构设计深度分析）
            fetch_min_bytes=1048576,  # 1MB最小拉取量
            fetch_max_wait_ms=500,  # 最多等待500ms
            max_partition_fetch_bytes=10485760,  # 10MB单分区最大拉取量
            max_poll_records=500,  # 每次poll最多拉取500条
            max_poll_interval_ms=300000,  # 5分钟超时
            
            # 序列化配置
            key_deserializer=lambda k: k.decode('utf-8') if k else None,
            value_deserializer=lambda v: json.loads(v.decode('utf-8')),
            
            # 其他配置
            session_timeout_ms=30000,
            heartbeat_interval_ms=3000,
        )
    
    def subscribe(self, topics):
        """订阅主题"""
        self.consumer.subscribe(topics)
        logger.info(f"已订阅主题: {topics}")
    
    def consume_messages(self, timeout_ms=100):
        """消费消息"""
        try:
            # 拉取消息
            message_pack = self.consumer.poll(timeout_ms=timeout_ms)
            
            for topic_partition, messages in message_pack.items():
                for message in messages:
                    try:
                        # 处理消息
                        self.process_message(message)
                        
                    except Exception as e:
                        logger.error(f"处理消息失败: {e}, offset={message.offset}")
                        # 记录到死信队列或跳过
                        continue
            
            # 手动提交offset（参考：03-03-故障场景与恢复策略）
            self.consumer.commit()
            
        except KafkaError as e:
            logger.error(f"消费消息失败: {e}")
    
    def process_message(self, message):
        """处理单条消息"""
        logger.info(
            f"收到消息: topic={message.topic}, "
            f"partition={message.partition}, "
            f"offset={message.offset}, "
            f"key={message.key}, "
            f"value={message.value}"
        )
        
        # 业务逻辑处理
        # ...
    
    def consume_loop(self):
        """消费循环"""
        try:
            while True:
                self.consume_messages()
        except KeyboardInterrupt:
            logger.info("停止消费")
        finally:
            self.close()
    
    def get_consumer_lag(self):
        """获取Consumer Lag"""
        partitions = self.consumer.assignment()
        end_offsets = self.consumer.end_offsets(partitions)
        
        lag_info = {}
        for partition in partitions:
            current_offset = self.consumer.position(partition)
            end_offset = end_offsets.get(partition, 0)
            lag = end_offset - current_offset
            lag_info[partition] = lag
            
            if lag > 10000:
                logger.warning(f"高Lag警告: partition={partition}, lag={lag}")
        
        return lag_info
    
    def close(self):
        """关闭Consumer"""
        self.consumer.close()


def main():
    """主函数"""
    consumer = KafkaConsumerExample('localhost:9092', 'test-group')
    
    try:
        # 订阅主题
        consumer.subscribe(['test-topic'])
        
        # 消费消息循环
        consumer.consume_loop()
        
    except Exception as e:
        logger.error(f"Consumer异常: {e}")
    finally:
        consumer.close()


if __name__ == '__main__':
    main()
