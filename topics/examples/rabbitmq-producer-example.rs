// RabbitMQ Producer示例 (Rust)
// 依赖: amqprs = "0.10"

use amqprs::{
    channel::{BasicPublishArguments, Channel},
    connection::{Connection, OpenConnectionArguments},
    BasicProperties,
};
use tokio;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 连接RabbitMQ
    let args = OpenConnectionArguments::new("localhost", 5672, "guest", "guest");
    let connection = Connection::open(&args).await?;
    let channel = connection.open_channel(None).await?;

    // 声明Exchange
    channel
        .exchange_declare(
            "order_exchange",
            "direct",
            false,
            false,
            false,
            false,
            None,
        )
        .await?;

    // 声明Queue
    channel
        .queue_declare("order_queue", false, false, false, false, false, None)
        .await?;

    // 绑定Queue到Exchange
    channel
        .queue_bind(
            "order_queue",
            "order_exchange",
            "order.created",
            false,
            None,
        )
        .await?;

    // 发送消息
    for i in 0..10 {
        let message = format!(
            r#"{{"order_id":"ORD-{:04}","user_id":"USER-{}","amount":{:.2}}}"#,
            i, i, 100.0 + i as f64
        );

        let args = BasicPublishArguments::new("order_exchange", "order.created");
        channel
            .basic_publish(
                BasicProperties::default(),
                message.as_bytes().to_vec(),
                args,
            )
            .await?;

        println!("Sent: ORD-{:04}", i);
    }

    channel.close().await?;
    connection.close().await?;

    println!("Messages sent successfully");
    Ok(())
}
