// 链#5（01-82）：x-jetstream（maxAckPending/ackPolicy）→ nats.go → nats-server.conf 映射示例
// 对应矩阵用例：TC-NATS-GO-BCK-01（ASE-010 平台期断言）
// 绑定声明: operations.*.x-jetstream.{stream,durable,maxAckPending,ackPolicy}（bindings-matrix 登记簿）

package main

import (
	"fmt"
	"time"

	"github.com/nats-io/nats.go"
)

func main() {
	nc, _ := nats.Connect(nats.DefaultURL)
	js, _ := nc.JetStream()

	// 消费端：maxAckPending=100 → 背压格 NATS=● 的客户端载体
	sub, _ := js.PullSubscribe("tasks.generic", "task-workers-durable",
		nats.ManualAck(),
		nats.MaxAckPending(100),          // == x-jetstream.maxAckPending（T3 一致性）
		nats.AckExplicit(),               // == x-jetstream.ackPolicy: explicit
		nats.MaxDeliver(5),               // == x-jetstream.maxDeliver（死信格=◐ 的触发器）
		nats.BackOff([]time.Duration{time.Second, 5*time.Second, 30*time.Second, 2*time.Minute, 10*time.Minute}), // == backoff 序列（重试退避格=●）
	)
	msgs, _ := sub.Fetch(10)
	for _, m := range msgs {
		fmt.Println(string(m.Data))
		m.Ack()
	}
	// 对账点：客户端参数 == x- 扩展声明 == 审计可查（01-66 观测族）
}
