/**
 * Kafka Consumer示例代码
 * 
 * 功能：演示Kafka Consumer的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 */

import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class KafkaConsumerExample {
    
    public static void main(String[] args) {
        // 1. 配置Consumer属性
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "my-consumer-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        
        // 可靠性配置（参考：01-04-形式化证明框架）
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); // 从最早开始消费
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false"); // 手动提交offset
        
        // 性能优化配置（参考：01-06-架构设计深度分析）
        props.put(ConsumerConfig.FETCH_MIN_BYTES_CONFIG, "1024"); // 最小拉取1KB
        props.put(ConsumerConfig.FETCH_MAX_WAIT_MS_CONFIG, "500"); // 最多等待500ms
        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, "500"); // 每次最多拉取500条
        
        // 2. 创建Consumer实例
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        
        // 3. 订阅Topic
        consumer.subscribe(Collections.singletonList("my-topic"));
        
        // 4. 消费消息
        try {
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
                
                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("消费消息: topic=%s, partition=%d, offset=%d, key=%s, value=%s%n",
                        record.topic(), record.partition(), record.offset(),
                        record.key(), record.value());
                    
                    // 处理消息逻辑
                    processMessage(record);
                }
                
                // 手动提交offset（保证至少一次投递）
                consumer.commitSync();
            }
        } finally {
            consumer.close();
        }
    }
    
    private static void processMessage(ConsumerRecord<String, String> record) {
        // 消息处理逻辑
        // 注意：处理失败时不要提交offset，实现重试机制
    }
}

/**
 * 最佳实践：
 * 1. 使用Consumer Group实现负载均衡
 * 2. 手动提交offset保证消息处理完成
 * 3. 批量拉取提高效率
 * 4. 实现幂等性处理避免重复消费
 * 
 * 参考文档：
 * - [01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
 * - [03-03-故障场景与恢复策略](../03-架构与运维实践/03-03-故障场景与恢复策略.md)
 */
