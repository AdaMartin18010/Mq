/**
 * Kafka Consumer示例代码 (Rust)
 *
 * 功能：演示Kafka Consumer的基本用法和最佳实践
 * 参考：[01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
 * 依赖：rdkafka = "0.36"
 */

use rdkafka::config::ClientConfig;
use rdkafka::consumer::{Consumer, StreamConsumer};
use rdkafka::Message;
use std::time::Duration;

pub struct KafkaConsumerExample {
    consumer: StreamConsumer,
}

impl KafkaConsumerExample {
    pub fn new(brokers: &str, group_id: &str, topic: &str) -> Self {
        let consumer: StreamConsumer = ClientConfig::new()
            .set("bootstrap.servers", brokers)
            .set("group.id", group_id)
            // 消费配置（参考：01-04-形式化证明框架）
            .set("enable.auto.commit", "false") // 手动提交offset
            .set("auto.offset.reset", "earliest") // 从最早的消息开始消费
            // 性能优化配置（参考：01-06-架构设计深度分析）
            .set("fetch.min.bytes", "1048576") // 1MB最小拉取量
            .set("fetch.max.wait.ms", "500") // 最多等待500ms
            .set("max.partition.fetch.bytes", "10485760") // 10MB单分区最大拉取量
            .create()
            .expect("Consumer创建失败");

        consumer
            .subscribe(&[topic])
            .expect("订阅主题失败");

        KafkaConsumerExample { consumer }
    }

    pub async fn consume_messages(&self) -> Result<(), Box<dyn std::error::Error>> {
        loop {
            match self.consumer.recv().await {
                Ok(message) => {
                    match message.payload_view::<str>() {
                        None => continue,
                        Some(Ok(payload)) => {
                            println!(
                                "收到消息: topic={}, partition={}, offset={}, key={:?}, payload={}",
                                message.topic(),
                                message.partition(),
                                message.offset(),
                                message.key(),
                                payload
                            );

                            // 处理消息
                            self.process_message(payload)?;

                            // 手动提交offset（参考：03-03-故障场景与恢复策略）
                            self.consumer.commit_message(&message, rdkafka::consumer::CommitMode::Async)?;
                        }
                        Some(Err(e)) => {
                            eprintln!("解析消息失败: {}", e);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("消费消息失败: {}", e);
                    return Err(Box::new(e));
                }
            }
        }
    }

    fn process_message(&self, payload: &str) -> Result<(), Box<dyn std::error::Error>> {
        // 业务逻辑处理
        println!("处理消息: {}", payload);
        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let consumer = KafkaConsumerExample::new("localhost:9092", "test-group", "test-topic");

    // 消费消息循环
    consumer.consume_messages().await?;

    Ok(())
}
