// Pulsar Rust Consumer容错异常处理示例
// 基于concept06.md和Pulsar官方文档

use pulsar::{Consumer, Error, Pulsar, TokioExecutor};
use std::time::Duration;
use tokio::time::sleep;

/// 带容错机制的Pulsar Consumer
pub struct RobustPulsarConsumer {
    consumer: Consumer<String, TokioExecutor>,
    dlq_producer: Option<pulsar::Producer<TokioExecutor>>,
}

impl RobustPulsarConsumer {
    /// 创建新的Consumer
    pub async fn new(
        service_url: &str,
        topic: &str,
        subscription_name: &str,
    ) -> Result<Self, Error> {
        let pulsar = Pulsar::builder(service_url, TokioExecutor)
            .connection_timeout(Duration::from_secs(10))
            .build()
            .await?;

        let consumer = pulsar
            .consumer()
            .topic(topic)
            .subscription_name(subscription_name)
            .ack_timeout(Duration::from_secs(30))
            .negative_ack_redelivery_delay(Duration::from_secs(60))
            .subscribe()
            .await?;

        // 创建死信队列Producer（可选）
        let dlq_producer = None; // 简化示例

        Ok(Self {
            consumer,
            dlq_producer,
        })
    }

    /// 带异常处理的消息消费
    pub async fn consume_with_error_handling(&mut self) -> Result<(), Error> {
        loop {
            match self.consumer.try_recv().await {
                Ok(Some(msg)) => {
                    match self.process_message(&msg).await {
                        Ok(_) => {
                            // 处理成功，确认消息
                            self.consumer.ack(&msg).await?;
                        }
                        Err(e) => {
                            eprintln!("Failed to process message: {:?}", e);
                            
                            if self.is_retriable_error(&e) {
                                // 可重试错误，否定确认（自动重试）
                                self.consumer.nack(&msg).await?;
                            } else {
                                // 不可重试错误，确认消息并发送到死信队列
                                self.consumer.ack(&msg).await?;
                                self.send_to_dlq(&msg, &e).await;
                            }
                        }
                    }
                }
                Ok(None) => {
                    // 没有消息，等待
                    sleep(Duration::from_millis(100)).await;
                }
                Err(e) => {
                    eprintln!("Receive error: {:?}", e);
                    self.handle_consumer_error(&e).await;
                    sleep(Duration::from_secs(1)).await;
                }
            }
        }
    }

    /// 处理消息
    async fn process_message(&self, msg: &pulsar::Message<String>) -> Result<(), Error> {
        // 业务逻辑处理
        let content = msg.deserialize();
        eprintln!("Processing message: {:?}", content);
        
        // 模拟处理失败
        // if some_condition {
        //     return Err(Error::Custom("Processing failed".to_string()));
        // }
        
        Ok(())
    }

    /// 判断错误是否可重试
    fn is_retriable_error(&self, error: &Error) -> bool {
        // 临时错误可重试，永久错误不可重试
        matches!(error, Error::ConnectionError(_) | Error::Timeout(_))
    }

    /// 发送到死信队列
    async fn send_to_dlq(&self, msg: &pulsar::Message<String>, error: &Error) {
        if let Some(ref producer) = self.dlq_producer {
            // 发送到死信队列
            eprintln!("Sending to DLQ: {:?}", error);
            // producer.send(...).await;
        } else {
            eprintln!("DLQ not configured, message lost: {:?}", error);
        }
    }

    /// 处理Consumer错误
    async fn handle_consumer_error(&self, error: &Error) {
        eprintln!("Consumer error: {:?}", error);
        // 可以在这里实现重连逻辑、告警等
    }
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    let mut consumer = RobustPulsarConsumer::new(
        "pulsar://localhost:6650",
        "my-topic",
        "my-subscription",
    )
    .await?;

    consumer.consume_with_error_handling().await?;

    Ok(())
}
