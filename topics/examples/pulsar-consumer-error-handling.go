// Pulsar Go Consumer容错异常处理示例
// 基于concept06.md和Pulsar官方文档

package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/apache/pulsar-client-go/pulsar"
)

// RobustPulsarConsumer 带容错机制的Pulsar Consumer
type RobustPulsarConsumer struct {
	client      pulsar.Client
	consumer    pulsar.Consumer
	dlqProducer pulsar.Producer  // 死信队列Producer
}

// NewRobustPulsarConsumer 创建带容错的Consumer
func NewRobustPulsarConsumer(serviceURL, topic, subscriptionName string) (*RobustPulsarConsumer, error) {
	client, err := pulsar.NewClient(pulsar.ClientOptions{
		URL:               serviceURL,
		ConnectionTimeout: 10 * time.Second,
		OperationTimeout:  30 * time.Second,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create client: %w", err)
	}

	consumer, err := client.Subscribe(pulsar.ConsumerOptions{
		Topic:                       topic,
		SubscriptionName:            subscriptionName,
		Type:                        pulsar.Shared,
		AckTimeout:                  30 * time.Second,
		NegativeAckRedeliveryDelay:  1 * time.Minute,
		ReceiverQueueSize:            1000,
		MaxPendingChunkedMessage:     10,
		AutoAckOldestChunkedMessageOnQueueFull: true,
	})
	if err != nil {
		client.Close()
		return nil, fmt.Errorf("failed to create consumer: %w", err)
	}

	// 创建死信队列Producer
	dlqProducer, err := client.CreateProducer(pulsar.ProducerOptions{
		Topic: fmt.Sprintf("%s-dlq", topic),
	})
	if err != nil {
		consumer.Close()
		client.Close()
		return nil, fmt.Errorf("failed to create DLQ producer: %w", err)
	}

	return &RobustPulsarConsumer{
		client:      client,
		consumer:    consumer,
		dlqProducer: dlqProducer,
	}, nil
}

// ConsumeWithErrorHandling 带异常处理的消息消费
func (c *RobustPulsarConsumer) ConsumeWithErrorHandling(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		default:
			// 接收消息（带超时）
			msg, err := c.consumer.Receive(ctx)
			if err != nil {
				if err == context.DeadlineExceeded {
					// 超时，继续接收
					continue
				}
				log.Printf("Receive error: %v", err)
				c.handleConsumerError(err)
				continue
			}

			// 处理消息
			if err := c.processMessage(msg); err != nil {
				log.Printf("Failed to process message: %v", err)
				
				// 判断错误类型
				if c.isRetriableError(err) {
					// 可重试错误，否定确认（自动重试）
					c.consumer.Nack(msg)
				} else {
					// 不可重试错误，确认消息并发送到死信队列
					c.consumer.Ack(msg)
					c.sendToDLQ(msg, err)
				}
			} else {
				// 处理成功，确认消息
				c.consumer.Ack(msg)
			}
		}
	}
}

// processMessage 处理消息
func (c *RobustPulsarConsumer) processMessage(msg pulsar.Message) error {
	// 业务逻辑处理
	content := string(msg.Payload())
	log.Printf("Processing message: %s", content)
	
	// 模拟处理失败
	// if someCondition {
	//     return fmt.Errorf("processing failed")
	// }
	
	return nil
}

// isRetriableError 判断错误是否可重试
func (c *RobustPulsarConsumer) isRetriableError(err error) bool {
	// 临时错误可重试，永久错误不可重试
	// 例如：网络错误、超时错误可重试
	// 数据格式错误、业务逻辑错误不可重试
	return true  // 简化示例，实际应根据错误类型判断
}

// sendToDLQ 发送到死信队列
func (c *RobustPulsarConsumer) sendToDLQ(msg pulsar.Message, err error) {
	dlqMsg := &pulsar.ProducerMessage{
		Payload: msg.Payload(),
		Properties: map[string]string{
			"original_topic":    msg.Topic(),
			"original_msg_id":   msg.ID().String(),
			"error":             err.Error(),
			"timestamp":         time.Now().Format(time.RFC3339),
		},
	}

	_, sendErr := c.dlqProducer.Send(context.Background(), dlqMsg)
	if sendErr != nil {
		log.Printf("Failed to send to DLQ: %v", sendErr)
	} else {
		log.Printf("Message sent to DLQ: %s", msg.ID())
	}
}

// handleConsumerError 处理Consumer错误
func (c *RobustPulsarConsumer) handleConsumerError(err error) {
	// 根据错误类型处理
	log.Printf("Consumer error: %v", err)
	// 可以在这里实现重连逻辑、告警等
}

// Close 关闭Consumer和Client
func (c *RobustPulsarConsumer) Close() {
	c.dlqProducer.Close()
	c.consumer.Close()
	c.client.Close()
}

func main() {
	consumer, err := NewRobustPulsarConsumer(
		"pulsar://localhost:6650",
		"my-topic",
		"my-subscription",
	)
	if err != nil {
		log.Fatal(err)
	}
	defer consumer.Close()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// 启动消费
	go consumer.ConsumeWithErrorHandling(ctx)

	// 保持运行
	select {}
}
