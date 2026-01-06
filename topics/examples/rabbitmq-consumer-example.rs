// RabbitMQ Consumer示例 (Rust)
// 依赖: amqprs = "0.10", tokio = "1.0"

use amqprs::{
    channel::{BasicAckArguments, BasicConsumeArguments, Channel},
    connection::{Connection, OpenConnectionArguments},
    consumer::AsyncConsumer,
    BasicProperties, Deliver,
};
use tokio;

struct OrderConsumer;

#[async_trait::async_trait]
impl AsyncConsumer for OrderConsumer {
    async fn consume(
        &mut self,
        channel: &Channel,
        deliver: Deliver,
        _basic_properties: BasicProperties,
        _content: Vec<u8>,
    ) {
        println!("Received: {:?}", deliver);
        
        // 处理消息
        // process_order(&content);
        
        // 确认消息
        let args = BasicAckArguments::new(deliver.delivery_tag(), false);
        channel.basic_ack(args).await.unwrap();
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 连接RabbitMQ
    let args = OpenConnectionArguments::new("localhost", 5672, "guest", "guest");
    let connection = Connection::open(&args).await?;
    let channel = connection.open_channel(None).await?;

    // 声明Queue
    channel
        .queue_declare("order_queue", false, false, false, false, false, None)
        .await?;

    // 设置预取数量
    channel.basic_qos(1, false, false).await?;

    // 开始消费
    let args = BasicConsumeArguments::new("order_queue", "consumer-1");
    let (_ctag, _receiver) = channel.basic_consume(OrderConsumer, args).await?;

    println!("Waiting for messages. To exit press CTRL+C");
    
    // 保持运行
    tokio::signal::ctrl_c().await?;
    
    channel.close().await?;
    connection.close().await?;

    Ok(())
}
