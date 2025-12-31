/**
 * Kafka Producer示例代码 (Go)
 *
 * 功能：演示Kafka Producer的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
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

type KafkaProducerExample struct {
	writer *kafka.Writer
}

func NewKafkaProducer(brokers []string) *KafkaProducerExample {
	// 创建Writer配置
	writer := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Balancer: &kafka.LeastBytes{}, // 负载均衡策略

		// 可靠性配置（参考：01-04-形式化证明框架）
		RequiredAcks: kafka.RequireAll, // 等待所有ISR副本确认
		Async:        false,            // 同步发送

		// 性能优化配置（参考：01-06-架构设计深度分析）
		BatchSize:    16384,                 // 16KB批量大小
		BatchTimeout: 10 * time.Millisecond, // 等待10ms批量发送
		Compression:  kafka.Snappy,          // 压缩算法

		// 其他配置
		WriteTimeout: 10 * time.Second,
		ReadTimeout:  10 * time.Second,
	}

	return &KafkaProducerExample{writer: writer}
}

func (p *KafkaProducerExample) SendMessage(ctx context.Context, topic string, key string, value interface{}) error {
	// 序列化value
	valueBytes, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("序列化失败: %w", err)
	}

	// 发送消息
	message := kafka.Message{
		Topic: topic,
		Key:   []byte(key),
		Value: valueBytes,
	}

	err = p.writer.WriteMessages(ctx, message)
	if err != nil {
		return fmt.Errorf("发送消息失败: %w", err)
	}

	log.Printf("消息发送成功: topic=%s, key=%s", topic, key)
	return nil
}

func (p *KafkaProducerExample) SendBatch(ctx context.Context, topic string, messages []map[string]interface{}) error {
	kafkaMessages := make([]kafka.Message, 0, len(messages))

	for _, msg := range messages {
		valueBytes, err := json.Marshal(msg["value"])
		if err != nil {
			return fmt.Errorf("序列化失败: %w", err)
		}

		kafkaMessages = append(kafkaMessages, kafka.Message{
			Topic: topic,
			Key:   []byte(msg["key"].(string)),
			Value: valueBytes,
		})
	}

	err := p.writer.WriteMessages(ctx, kafkaMessages...)
	if err != nil {
		return fmt.Errorf("批量发送失败: %w", err)
	}

	log.Printf("批量消息发送成功: count=%d", len(messages))
	return nil
}

func (p *KafkaProducerExample) Close() error {
	return p.writer.Close()
}

func main() {
	producer := NewKafkaProducer([]string{"localhost:9092"})
	defer producer.Close()

	ctx := context.Background()

	// 发送单条消息
	err := producer.SendMessage(ctx, "test-topic", "user-123", map[string]interface{}{
		"action":    "login",
		"timestamp": time.Now().Unix(),
	})
	if err != nil {
		log.Fatal(err)
	}

	// 批量发送消息
	messages := []map[string]interface{}{
		{"key": "key-1", "value": map[string]interface{}{"id": 1, "data": "message-1"}},
		{"key": "key-2", "value": map[string]interface{}{"id": 2, "data": "message-2"}},
	}
	err = producer.SendBatch(ctx, "test-topic", messages)
	if err != nil {
		log.Fatal(err)
	}
}
