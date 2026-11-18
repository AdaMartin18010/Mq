// 链#9（01-82）：x-redis（XREADGROUP count/block/noack）→ go-redis → redis-stream-config.conf 映射示例
// 对应矩阵用例：TC-REDIS-GO-DLV-01（ASE-014：重启不丢）
// 绑定声明: redis binding 全保留（0.1.0）→ x-redis 扩展承载全部语义（bindings-matrix §三）

package main

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
)

func main() {
	ctx := context.Background()
	rdb := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

	// 消费组：背压格 Redis=○——无原生背压，轮询补偿（01-66）的客户端形态
	res, err := rdb.XReadGroup(ctx, &redis.XReadGroupArgs{
		Group:    "order-consumers", // == x-redis.group
		Consumer: "order-service-1", // == x-redis.consumer
		Streams:  []string{"stream:orders:events", ">"},
		Count:    100,              // == x-redis.count
		Block:    5 * time.Second,  // == x-redis.block（毫秒→Duration）
		NoAck:    false,            // == x-redis.noack:false → 显式 ACK，PEL 即积压观测（01-66 观测族）
	}).Result()
	if err == nil {
		for _, stream := range res {
			for _, msg := range stream.Messages {
				rdb.XAck(ctx, "stream:orders:events", "order-consumers", msg.ID)
			}
		}
	}
	// 对账点：ASE-014（AOF everysec + 重启 XLEN/ID 保持）；持久化格 Redis=● 的客户端前提
}
