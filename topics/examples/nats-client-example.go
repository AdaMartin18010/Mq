/**
 * NATS Client示例代码
 *
 * 功能：演示NATS客户端的基本用法和最佳实践
 * 参考：[02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
 */

package main

import (
	"fmt"
	"log"
	"time"

	"github.com/nats-io/nats.go"
)

func main() {
	// 1. 连接到NATS服务器（支持多个服务器地址，自动故障转移）
	nc, err := nats.Connect("nats://localhost:4222",
		nats.Name("example-client"),
		nats.ReconnectWait(1*time.Second),
		nats.MaxReconnects(10),
		nats.DisconnectErrHandler(func(nc *nats.Conn, err error) {
			if err != nil {
				log.Printf("连接断开: %v", err)
			}
		}),
		nats.ReconnectHandler(func(nc *nats.Conn) {
			log.Printf("重连成功")
		}),
	)
	if err != nil {
		log.Fatal(err)
	}
	defer nc.Close()

	// 2. 发布-订阅模式（参考：01-05-程序设计模式分析）
	subject := "events.user.created"

	// 订阅消息（事件驱动模式）
	sub, err := nc.Subscribe(subject, func(msg *nats.Msg) {
		fmt.Printf("收到消息: subject=%s, data=%s\n", msg.Subject, string(msg.Data))
		// 处理消息逻辑
		processEvent(msg)
	})
	if err != nil {
		log.Fatal(err)
	}
	defer sub.Unsubscribe()

	// 发布消息
	nc.Publish(subject, []byte("user created: 12345"))

	// 3. 请求-响应模式（参考：02-03-程序设计模式场景化应用）
	// 订阅请求
	nc.Subscribe("service.echo", func(msg *nats.Msg) {
		response := fmt.Sprintf("Echo: %s", string(msg.Data))
		msg.Respond([]byte(response))
	})

	// 发送请求
	response, err := nc.Request("service.echo", []byte("hello"), 1*time.Second)
	if err != nil {
		log.Printf("请求失败: %v", err)
	} else {
		fmt.Printf("收到响应: %s\n", string(response.Data))
	}

	// 4. 队列组模式（负载均衡）
	// 多个Subscriber订阅同一Subject，消息只投递给一个Subscriber
	nc.QueueSubscribe("tasks.process", "worker-group", func(msg *nats.Msg) {
		fmt.Printf("Worker处理任务: %s\n", string(msg.Data))
		msg.Ack() // JetStream模式需要ACK
	})

	// 5. JetStream模式（持久化流处理）
	js, err := nc.JetStream()
	if err != nil {
		log.Fatal(err)
	}

	// 创建Stream
	streamName := "ORDERS"
	_, err = js.AddStream(&nats.StreamConfig{
		Name:     streamName,
		Subjects: []string{"orders.>"},
		MaxAge:   24 * time.Hour, // 保留24小时
	})
	if err != nil {
		log.Printf("Stream可能已存在: %v", err)
	}

	// 发布到Stream
	_, err = js.Publish("orders.new", []byte("order data"))
	if err != nil {
		log.Fatal(err)
	}

	// 订阅Stream（Push模式）
	js.Subscribe("orders.>", func(msg *nats.Msg) {
		fmt.Printf("Stream消息: %s\n", string(msg.Data))
		msg.Ack()
	}, nats.Durable("order-processor"))

	// 保持运行
	time.Sleep(10 * time.Second)
}

func processEvent(msg *nats.Msg) {
	// 事件处理逻辑
	// 注意：NATS Core模式是fire-and-forget，无ACK机制
	// JetStream模式需要手动ACK
}

/**
 * 最佳实践：
 * 1. 使用多个服务器地址实现自动故障转移
 * 2. 实现重连处理，利用自动重连机制
 * 3. 使用队列组实现负载均衡
 * 4. JetStream模式用于需要持久化的场景
 *
 * 参考文档：
 * - [01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 * - [02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
 * - [04-03-负载动态响应与故障传播](../04-动态系统论与演化分析/04-03-负载动态响应与故障传播.md)
 */
