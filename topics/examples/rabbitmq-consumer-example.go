package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/streadway/amqp"
)

func main() {
	// 连接RabbitMQ
	conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	// 创建Channel
	ch, err := conn.Channel()
	if err != nil {
		log.Fatalf("Failed to open channel: %v", err)
	}
	defer ch.Close()

	// 声明Queue
	q, err := ch.QueueDeclare(
		"order_queue", // name
		true,          // durable
		false,         // delete when unused
		false,         // exclusive
		false,         // no-wait
		nil,           // arguments
	)
	if err != nil {
		log.Fatalf("Failed to declare queue: %v", err)
	}

	// 设置预取数量（公平分发）
	err = ch.Qos(
		1,     // prefetch count
		0,     // prefetch size
		false, // global
	)
	if err != nil {
		log.Fatalf("Failed to set QoS: %v", err)
	}

	// 消费消息
	msgs, err := ch.Consume(
		q.Name, // queue
		"",     // consumer
		false,  // auto-ack (手动确认)
		false,  // exclusive
		false,  // no-local
		false,  // no-wait
		nil,    // args
	)
	if err != nil {
		log.Fatalf("Failed to register consumer: %v", err)
	}

	fmt.Println("Waiting for messages. To exit press CTRL+C")

	for msg := range msgs {
		var message map[string]interface{}
		if err := json.Unmarshal(msg.Body, &message); err != nil {
			log.Printf("Error decoding message: %v", err)
			msg.Nack(false, true) // 重新入队
			continue
		}

		fmt.Printf("Received: %v\n", message)

		// 处理消息
		// processOrder(message)

		// 确认消息
		msg.Ack(false)
	}
}
