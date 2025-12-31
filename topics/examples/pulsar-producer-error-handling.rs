// Pulsar Rust Producer容错异常处理示例
// 基于concept06.md和Pulsar官方文档

use pulsar::{Error, Producer, Pulsar, TokioExecutor};
use std::time::{Duration, Instant};
use tokio::time::sleep;

/// 重试配置
pub struct RetryConfig {
    pub max_retries: u32,
    pub initial_delay: Duration,
}

impl Default for RetryConfig {
    fn default() -> Self {
        Self {
            max_retries: 3,
            initial_delay: Duration::from_secs(1),
        }
    }
}

/// 带容错机制的Pulsar Producer
pub struct RobustPulsarProducer {
    producer: Producer<TokioExecutor>,
    config: RetryConfig,
}

impl RobustPulsarProducer {
    /// 创建新的Producer
    pub async fn new(service_url: &str, topic: &str) -> Result<Self, Error> {
        let pulsar = Pulsar::builder(service_url, TokioExecutor)
            .connection_timeout(Duration::from_secs(10))
            .build()
            .await?;

        let producer = pulsar
            .producer()
            .with_topic(topic)
            .with_send_timeout(Duration::from_secs(30))
            .with_max_pending_messages(1000)
            .with_batching_max_messages(1000)
            .with_batching_max_publish_delay(Duration::from_millis(10))
            .build()
            .await?;

        Ok(Self {
            producer,
            config: RetryConfig::default(),
        })
    }

    /// 带重试的发送
    pub async fn send_with_retry(&mut self, message: Vec<u8>) -> Result<(), Error> {
        self.send_with_retry_config(message, self.config.clone()).await
    }

    /// 带自定义配置的重试发送
    pub async fn send_with_retry_config(
        &mut self,
        message: Vec<u8>,
        config: RetryConfig,
    ) -> Result<(), Error> {
        let mut last_error = None;

        for attempt in 0..config.max_retries {
            match self.producer.send(message.clone()).await {
                Ok(_) => {
                    eprintln!("Message sent successfully");
                    return Ok(());
                }
                Err(e) => {
                    last_error = Some(e.clone());

                    // 判断是否可重试
                    if !self.is_retriable(&e) {
                        return Err(e);
                    }

                    if attempt < config.max_retries - 1 {
                        // 指数退避
                        let delay = config.initial_delay * (1 << attempt);
                        eprintln!(
                            "Retry attempt {}/{} after {:?}: {:?}",
                            attempt + 1,
                            config.max_retries,
                            delay,
                            e
                        );
                        sleep(delay).await;
                    }
                }
            }
        }

        Err(last_error.unwrap_or_else(|| {
            Error::Custom("Max retries exceeded".to_string())
        }))
    }

    /// 判断错误是否可重试
    fn is_retriable(&self, error: &Error) -> bool {
        // 网络异常、超时异常可重试
        matches!(error, Error::ConnectionError(_) | Error::Timeout(_))
    }
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    let mut producer = RobustPulsarProducer::new("pulsar://localhost:6650", "my-topic").await?;

    // 发送消息
    producer
        .send_with_retry(b"Hello Pulsar".to_vec())
        .await?;

    Ok(())
}
