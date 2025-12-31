/**
 * Kafka Producer示例代码
 * 
 * 功能：演示Kafka Producer的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 */

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import java.util.Properties;

public class KafkaProducerExample {
    
    public static void main(String[] args) {
        // 1. 配置Producer属性
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        
        // 可靠性配置（参考：01-04-形式化证明框架）
        props.put(ProducerConfig.ACKS_CONFIG, "-1"); // 等待所有ISR副本确认
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true"); // 启用幂等性
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, "5");
        
        // 性能优化配置（参考：01-06-架构设计深度分析）
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, "16384"); // 16KB批量大小
        props.put(ProducerConfig.LINGER_MS_CONFIG, "10"); // 等待10ms批量发送
        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG, "snappy"); // 压缩算法
        
        // 2. 创建Producer实例
        KafkaProducer<String, String> producer = new KafkaProducer<>(props);
        
        // 3. 发送消息
        for (int i = 0; i < 100; i++) {
            ProducerRecord<String, String> record = new ProducerRecord<>(
                "my-topic",           // Topic名称
                "key-" + i,          // Key（用于分区路由）
                "value-" + i         // Value
            );
            
            // 异步发送（推荐）
            producer.send(record, new Callback() {
                @Override
                public void onCompletion(RecordMetadata metadata, Exception exception) {
                    if (exception == null) {
                        System.out.printf("消息发送成功: topic=%s, partition=%d, offset=%d%n",
                            metadata.topic(), metadata.partition(), metadata.offset());
                    } else {
                        System.err.println("消息发送失败: " + exception.getMessage());
                    }
                }
            });
        }
        
        // 4. 关闭Producer（确保所有消息都发送完成）
        producer.flush();
        producer.close();
    }
}

/**
 * 最佳实践：
 * 1. 使用批量发送提高吞吐量
 * 2. 启用幂等性保证恰好一次投递
 * 3. 使用回调处理发送结果
 * 4. 合理设置ACK级别平衡性能和可靠性
 * 
 * 参考文档：
 * - [01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
 * - [01-06-架构设计深度分析](../01-基础概念与对比分析/01-06-架构设计深度分析.md)
 */
