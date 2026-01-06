package main

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	// 创建Redis客户端
	rdb := redis.NewClient(&redis.Options{
		Addr: "localhost:6379",
		DB:   0,
	})
	defer rdb.Close()

	ctx := context.Background()
	streamName := "events:orders"

	// 发送消息
	for i := 0; i < 10; i++ {
		message := map[string]interface{}{
			"order_id":  fmt.Sprintf("ORD-%04d", i),
			"user_id":   fmt.Sprintf("USER-%d", i),
			"amount":    100.0 + float64(i),
			"timestamp": time.Now().Unix(),
		}

		// 序列化消息
		jsonData, _ := json.Marshal(message)
		msgData := map[string]interface{}{
			"data": string(jsonData),
		}

		// 添加消息到Stream
		msgID, err := rdb.XAdd(ctx, &redis.XAddArgs{
			Stream: streamName,
			MaxLen: 10000,
			Values: msgData,
		}).Result()

		if err != nil {
			fmt.Printf("Error: %v\n", err)
			continue
		}

		fmt.Printf("Sent: %s - %s\n", msgID, message["order_id"])
	}

	fmt.Println("Messages sent successfully")
}
