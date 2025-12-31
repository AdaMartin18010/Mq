/**
 * NATS Client示例代码 (Rust)
 *
 * 功能：演示NATS客户端的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 * 依赖：async-nats = "0.32"
 */

use async_nats::{Client, ConnectOptions};
use std::time::Duration;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 连接到NATS服务器
    let client = async_nats::connect("nats://localhost:4222").await?;
    println!("NATS连接成功");

    // 发布-订阅模式（参考：01-05-程序设计模式分析）
    let subject = "events.user.created";

    // 订阅消息
    let mut subscriber = client.subscribe(subject).await?;
    tokio::spawn(async move {
        while let Some(msg) = subscriber.next().await {
            println!("收到消息: subject={}, data={}", msg.subject, String::from_utf8_lossy(&msg.data));
        }
    });

    // 发布消息
    client.publish(subject, "user created: 12345".into()).await?;
    println!("已发布消息到主题: {}", subject);

    // 请求-响应模式（参考：02-03-程序设计模式场景化应用）
    let subject = "service.echo";

    // 订阅请求
    let mut subscriber = client.subscribe(subject).await?;
    tokio::spawn(async move {
        while let Some(msg) = subscriber.next().await {
            let response = format!("Echo: {}", String::from_utf8_lossy(&msg.data));
            if let Err(e) = msg.respond(response.into()).await {
                eprintln!("响应失败: {}", e);
            }
        }
    });

    // 发送请求
    let response = client.request(subject, "hello".into()).await?;
    println!("收到响应: {}", String::from_utf8_lossy(&response.data));

    // 队列组模式（负载均衡）
    let subject = "tasks.process";
    let queue_group = "worker-group";

    let mut subscriber = client.queue_subscribe(subject, queue_group).await?;
    tokio::spawn(async move {
        while let Some(msg) = subscriber.next().await {
            println!("处理任务: {}", String::from_utf8_lossy(&msg.data));
        }
    });

    // 发布任务
    for i in 0..5 {
        client.publish(subject, format!("task-{}", i).into()).await?;
    }

    tokio::time::sleep(Duration::from_secs(2)).await;

    Ok(())
}
