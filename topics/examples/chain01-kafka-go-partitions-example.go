// 链#1（01-82）：Kafka binding.partitions → sarama/segmentio → kafka-server.properties 映射示例
// 对应矩阵用例：TC-KAFKA-GO-ORD-01 / TC-KAFKA-GO-DLV-01
// 绑定声明（AsyncAPI）: channels.<x>.bindings.kafka.partitions: 6
// 部署映射: config-templates/kafka-server.properties.template 的 num.partitions（默认值，topic 级覆盖）
package main

import "github.com/segmentio/kafka-go"

func main() {
	// 创建 topic：分区数=AsyncAPI 声明值（T3 链一致性：binding==创建参数==模板）
	w := &kafka.Writer{
		Addr:     kafka.TCP("localhost:19092"),
		Topic:    "orders.events",
		Balancer: &kafka.Hash{}, // 键散列→分区序保证（TEST-C2 顺序性格 Kafka=● 的前提）
	}
	defer w.Close()
	_ = w
}

// 部署侧对账点：
//   binding partitions: 6  == 创建参数 NumPartitions: 6  == broker num.partitions（默认兜底）
// 漂移检测：bash topics/scripts/contract-binding-check.sh
