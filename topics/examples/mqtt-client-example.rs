/**
 * MQTT Client示例代码 (Rust)
 *
 * 功能：演示MQTT客户端的基本用法和最佳实践
 * 参考：[02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
 * 依赖：paho-mqtt = "0.12"
 */

use paho_mqtt as mqtt;
use std::time::Duration;

pub struct MQTTClientExample {
    client: mqtt::AsyncClient,
}

impl MQTTClientExample {
    pub fn new(broker: &str, client_id: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let create_opts = mqtt::CreateOptionsBuilder::new()
            .server_uri(broker)
            .client_id(client_id)
            .finalize();

        let client = mqtt::AsyncClient::new(create_opts)?;

        // 设置连接选项
        let conn_opts = mqtt::ConnectOptionsBuilder::new()
            .keep_alive_interval(Duration::from_secs(60))
            .clean_session(true)
            .finalize();

        // 设置遗嘱消息（参考：02-01-场景化功能架构矩阵）
        let will_msg = mqtt::MessageBuilder::new()
            .topic("home/device/status")
            .payload(r#"{"status":"offline"}"#)
            .qos(1)
            .retained(true)
            .finalize();

        let conn_opts = mqtt::ConnectOptionsBuilder::new()
            .keep_alive_interval(Duration::from_secs(60))
            .will_message(will_msg)
            .finalize();

        Ok(MQTTClientExample { client })
    }

    pub async fn connect(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.client.connect(None).await?;
        println!("MQTT连接成功");
        Ok(())
    }

    pub async fn subscribe(&self, topic: &str, qos: i32) -> Result<(), Box<dyn std::error::Error>> {
        self.client.subscribe(topic, qos).await?;
        println!("已订阅主题: {}, QoS: {}", topic, qos);
        Ok(())
    }

    pub async fn publish(&self, topic: &str, payload: &str, qos: i32) -> Result<(), Box<dyn std::error::Error>> {
        let msg = mqtt::MessageBuilder::new()
            .topic(topic)
            .payload(payload)
            .qos(qos)
            .finalize();

        self.client.publish(msg).await?;
        println!("已发布消息: topic={}, payload={}", topic, payload);
        Ok(())
    }

    pub async fn disconnect(&self) -> Result<(), Box<dyn std::error::Error>> {
        self.client.disconnect(None).await?;
        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = MQTTClientExample::new("tcp://localhost:1883", "rust-client")?;

    // 连接
    client.connect().await?;

    // 设置消息回调
    let rx = client.client.start_consuming();
    tokio::spawn(async move {
        for msg in rx.iter() {
            if let Some(msg) = msg {
                println!("收到消息: topic={}, payload={}", msg.topic(), msg.payload_str());
            }
        }
    });

    // 订阅主题
    client.subscribe("home/+/sensor/temperature", 1).await?;

    // 发布消息
    client.publish("home/room1/sensor/temperature", "25.5", 1).await?;

    // 保持连接
    tokio::time::sleep(Duration::from_secs(5)).await;

    // 断开连接
    client.disconnect().await?;

    Ok(())
}
