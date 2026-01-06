package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

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

	// 声明Exchange
	err = ch.ExchangeDeclare(
		"order_exchange", // name
		"direct",         // type
		true,             // durable
		false,            // auto-deleted
		false,            // internal
		false,            // no-wait
		nil,              // arguments
	)
	if err != nil {
		log.Fatalf("Failed to declare exchange: %v", err)
	}

	// 声明Queue
	_, err = ch.QueueDeclare(
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

	// 绑定Queue到Exchange
	err = ch.QueueBind(
		"order_queue",    // queue name
		"order.created",  // routing key
		"order_exchange", // exchange
		false,
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to bind queue: %v", err)
	}

	// 发送消息
	for i := 0; i < 10; i++ {
		message := map[string]interface{}{
			"order_id":  fmt.Sprintf("ORD-%04d", i),
			"user_id":   fmt.Sprintf("USER-%d", i),
			"amount":    100.0 + float64(i),
			"timestamp": time.Now().Unix(),
		}

		body, _ := json.Marshal(message)
		err = ch.Publish(
			"order_exchange", // exchange
			"order.created", // routing key
			false,            // mandatory
			false,            // immediate
			amqp.Publishing{
				ContentType:  "application/json",
				DeliveryMode: amqp.Persistent, // 持久化消息
				Body:          body,
			},
		)
		if err != nil {
			log.Fatalf("Failed to publish: %v", err)
		}
		fmt.Printf("Sent: %s\n", message["order_id"])
	}

	fmt.Println("Messages sent successfully")
}
