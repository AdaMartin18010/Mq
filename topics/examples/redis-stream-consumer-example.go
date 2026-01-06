package main

import (
	"context"
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
	groupName := "processors"
	consumerName := "consumer-1"

	// 创建消费者组（如果不存在）
	err := rdb.XGroupCreateMkStream(ctx, streamName, groupName, "0").Err()
	if err != nil && err.Error() != "BUSYGROUP Consumer Group name already exists" {
		fmt.Printf("Error creating group: %v\n", err)
		return
	}

	// 消费消息
	for {
		streams, err := rdb.XReadGroup(ctx, &redis.XReadGroupArgs{
			Group:    groupName,
			Consumer: consumerName,
			Streams:  []string{streamName, ">"},
			Count:    10,
			Block:    time.Second,
		}).Result()

		if err != nil {
			if err == redis.Nil {
				continue
			}
			fmt.Printf("Error reading: %v\n", err)
			continue
		}

		for _, stream := range streams {
			for _, message := range stream.Messages {
				fmt.Printf("Received: %s - %v\n", message.ID, message.Values)

				// 处理消息
				// processOrder(message.Values)

				// 确认消息
				rdb.XAck(ctx, streamName, groupName, message.ID)
			}
		}
	}
}
