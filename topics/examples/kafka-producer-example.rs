/**
 * Kafka Producer示例代码 (Rust)
 *
 * 功能：演示Kafka Producer的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 * 依赖：rdkafka = "0.36"
 */

use rdkafka::config::ClientConfig;
use rdkafka::producer::{FutureProducer, FutureRecord};
use rdkafka::util::Timeout;
use std::time::Duration;

pub struct KafkaProducerExample {
    producer: FutureProducer,
}

impl KafkaProducerExample {
    pub fn new(brokers: &str) -> Self {
        let producer: FutureProducer = ClientConfig::new()
            .set("bootstrap.servers", brokers)
            // 可靠性配置（参考：01-04-形式化证明框架）
            .set("acks", "all") // 等待所有ISR副本确认
            .set("retries", "3")
            .set("enable.idempotence", "true") // 启用幂等性
            // 性能优化配置（参考：01-06-架构设计深度分析）
            .set("batch.size", "16384") // 16KB批量大小
            .set("linger.ms", "10") // 等待10ms批量发送
            .set("compression.type", "snappy") // 压缩算法
            .create()
            .expect("Producer创建失败");

        KafkaProducerExample { producer }
    }

    pub async fn send_message(
        &self,
        topic: &str,
        key: &str,
        value: &str,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let record = FutureRecord::to(topic)
            .key(key)
            .payload(value);

        match self.producer.send(record, Timeout::After(Duration::from_secs(10))).await {
            Ok(delivery) => {
                println!(
                    "消息发送成功: topic={}, partition={}, offset={}",
                    delivery.0.topic(),
                    delivery.0.partition(),
                    delivery.0.offset().unwrap_or(-1)
                );
                Ok(())
            }
            Err((e, _)) => {
                eprintln!("发送消息失败: {}", e);
                Err(Box::new(e))
            }
        }
    }

    pub async fn send_batch(
        &self,
        topic: &str,
        messages: Vec<(&str, &str)>,
    ) -> Result<(), Box<dyn std::error::Error>> {
        for (key, value) in messages {
            self.send_message(topic, key, value).await?;
        }
        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let producer = KafkaProducerExample::new("localhost:9092");

    // 发送单条消息
    producer
        .send_message("test-topic", "user-123", r#"{"action":"login"}"#)
        .await?;

    // 批量发送消息
    let messages = vec![
        ("key-1", r#"{"id":1,"data":"message-1"}"#),
        ("key-2", r#"{"id":2,"data":"message-2"}"#),
    ];
    producer.send_batch("test-topic", messages).await?;

    Ok(())
}
