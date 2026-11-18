// 链#7（01-82）：AMQP binding + x-prefetch → amqp091-go → rabbitmq.conf 映射示例
// 对应矩阵用例：TC-RABBITMQ-GO-BCK-01（ASE-011：prefetch 平台期）
// 绑定声明: channels.*.bindings.amqp.{is,exchange,queue} + operations.*.x-prefetch.count: 50

package main

import amqp "github.com/rabbitmq/amqp091-go"

func main() {
	conn, _ := amqp.Dial("amqp://localhost:5672")
	ch, _ := conn.Channel()
	defer ch.Close()

	// exchange/queue 声明与 channel binding 对齐（deliveryMode:2=persistent，持久化格=●）
	_ = ch.ExchangeDeclare("orders.events", "topic", true, false, false, false, nil)
	q, _ := ch.QueueDeclare("orders.notifications", true, false, false, false, nil)
	_ = ch.QueueBind(q.Name, "orders.#", "orders.events", false, nil)

	// x-prefetch.count: 50 → 背压格 RabbitMQ=● 的客户端载体（ASE-011 平台期=50）
	_ = ch.Qos(50, 0, false) // prefetch_count=50, global=false

	// 对账点：客户端 Qos == x-prefetch.count == 未确认数平台期断言输入
}
