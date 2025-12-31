/**
 * Kafka Consumer示例代码 (Go)
 *
 * 功能：演示Kafka Consumer的基本用法和最佳实践
 * 参考：[01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
 * 依赖：go get github.com/segmentio/kafka-go
 */

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/segmentio/kafka-go"
)

type KafkaConsumerExample struct {
	reader *kafka.Reader
}

func NewKafkaConsumer(brokers []string, topic string, groupID string) *KafkaConsumerExample {
	// 创建Reader配置
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: brokers,
		Topic:   topic,
		GroupID: groupID,

		// 消费配置（参考：01-04-形式化证明框架）
		MinBytes: 1048576,                // 1MB最小拉取量
		MaxBytes: 10485760,               // 10MB最大拉取量
		MaxWait:  500 * time.Millisecond, // 最多等待500ms

		// 其他配置
		StartOffset: kafka.FirstOffset, // 从最早的消息开始
	})

	return &KafkaConsumerExample{reader: reader}
}

func (c *KafkaConsumerExample) ConsumeMessages(ctx context.Context) error {
	for {
		// 拉取消息
		message, err := c.reader.ReadMessage(ctx)
		if err != nil {
			return fmt.Errorf("读取消息失败: %w", err)
		}

		// 处理消息
		err = c.processMessage(message)
		if err != nil {
			log.Printf("处理消息失败: %v, offset=%d", err, message.Offset)
			// 记录到死信队列或跳过
			continue
		}

		// 手动提交offset（参考：03-03-故障场景与恢复策略）
		// Reader会自动提交offset
	}
}

func (c *KafkaConsumerExample) processMessage(message kafka.Message) error {
	var value map[string]interface{}
	err := json.Unmarshal(message.Value, &value)
	if err != nil {
		return fmt.Errorf("反序列化失败: %w", err)
	}

	log.Printf(
		"收到消息: topic=%s, partition=%d, offset=%d, key=%s, value=%v",
		message.Topic,
		message.Partition,
		message.Offset,
		string(message.Key),
		value,
	)

	// 业务逻辑处理
	// ...

	return nil
}

func (c *KafkaConsumerExample) Close() error {
	return c.reader.Close()
}

func main() {
	consumer := NewKafkaConsumer(
		[]string{"localhost:9092"},
		"test-topic",
		"test-group",
	)
	defer consumer.Close()

	ctx := context.Background()

	// 消费消息循环
	err := consumer.ConsumeMessages(ctx)
	if err != nil {
		log.Fatal(err)
	}
}
