// Pulsar Go Producer容错异常处理示例
// 基于concept06.md和Pulsar官方文档

package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/apache/pulsar-client-go/pulsar"
)

// RobustPulsarProducer 带容错机制的Pulsar Producer
type RobustPulsarProducer struct {
	client      pulsar.Client
	producer    pulsar.Producer
	maxRetries  int
	initialDelay time.Duration
}

// NewRobustPulsarProducer 创建带容错的Producer
func NewRobustPulsarProducer(serviceURL, topic string) (*RobustPulsarProducer, error) {
	client, err := pulsar.NewClient(pulsar.ClientOptions{
		URL:               serviceURL,
		ConnectionTimeout: 10 * time.Second,
		OperationTimeout:  30 * time.Second,
		// 多Broker故障转移
		URL: "pulsar://broker1:6650,broker2:6650,broker3:6650",
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create client: %w", err)
	}

	producer, err := client.CreateProducer(pulsar.ProducerOptions{
		Topic:                   topic,
		SendTimeout:            30 * time.Second,
		MaxPendingMessages:      1000,
		BlockIfQueueFull:        true,  // 队列满时阻塞，避免消息丢失
		BatchingMaxMessages:     1000,
		BatchingMaxPublishDelay: 10 * time.Millisecond,
	})
	if err != nil {
		client.Close()
		return nil, fmt.Errorf("failed to create producer: %w", err)
	}

	return &RobustPulsarProducer{
		client:       client,
		producer:     producer,
		maxRetries:   3,
		initialDelay: 1 * time.Second,
	}, nil
}

// SendWithRetry 带重试的发送
func (p *RobustPulsarProducer) SendWithRetry(ctx context.Context, message []byte) (pulsar.MessageID, error) {
	var lastErr error

	for attempt := 0; attempt < p.maxRetries; attempt++ {
		msgID, err := p.producer.Send(ctx, &pulsar.ProducerMessage{
			Payload: message,
		})

		if err == nil {
			log.Printf("Message sent successfully: %v", msgID)
			return msgID, nil
		}

		lastErr = err

		// 判断是否可重试
		if !p.isRetriable(err) {
			return nil, fmt.Errorf("non-retriable error: %w", err)
		}

		if attempt < p.maxRetries-1 {
			// 指数退避
			delay := p.initialDelay * time.Duration(1<<uint(attempt))
			log.Printf("Retry attempt %d/%d after %v: %v", attempt+1, p.maxRetries, delay, err)
			time.Sleep(delay)
		}
	}

	return nil, fmt.Errorf("failed after %d attempts: %w", p.maxRetries, lastErr)
}

// isRetriable 判断错误是否可重试
func (p *RobustPulsarProducer) isRetriable(err error) bool {
	// 网络异常、超时异常可重试
	if err == context.DeadlineExceeded {
		return true
	}
	// 可以添加更多可重试的异常类型判断
	// 例如：连接错误、临时不可用等
	return true
}

// SendAsyncWithCallback 异步发送带回调
func (p *RobustPulsarProducer) SendAsyncWithCallback(ctx context.Context, message []byte, 
	callback func(pulsar.MessageID, error)) {
	p.producer.SendAsync(ctx, &pulsar.ProducerMessage{
		Payload: message,
	}, func(msgID pulsar.MessageID, err error) {
		if err != nil {
			log.Printf("Async send failed: %v", err)
			// 可以在这里实现重试逻辑
			if p.isRetriable(err) {
				// 重试
				time.Sleep(p.initialDelay)
				p.SendAsyncWithCallback(ctx, message, callback)
			} else {
				callback(nil, err)
			}
		} else {
			callback(msgID, nil)
		}
	})
}

// Close 关闭Producer和Client
func (p *RobustPulsarProducer) Close() {
	p.producer.Close()
	p.client.Close()
}

func main() {
	producer, err := NewRobustPulsarProducer("pulsar://localhost:6650", "my-topic")
	if err != nil {
		log.Fatal(err)
	}
	defer producer.Close()

	ctx := context.Background()

	// 同步发送带重试
	msgID, err := producer.SendWithRetry(ctx, []byte("Hello Pulsar"))
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("Sent message: %v", msgID)

	// 异步发送带回调
	producer.SendAsyncWithCallback(ctx, []byte("Hello Pulsar Async"), func(msgID pulsar.MessageID, err error) {
		if err != nil {
			log.Printf("Async send failed: %v", err)
		} else {
			log.Printf("Async send succeeded: %v", msgID)
		}
	})

	time.Sleep(2 * time.Second)
}
