package com.example.mq;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.StreamEntry;
import redis.clients.jedis.StreamEntryID;
import redis.clients.jedis.params.XReadGroupParams;
import java.util.List;
import java.util.Map;

public class RedisStreamConsumer {
    private static final String STREAM_NAME = "events:orders";
    private static final String GROUP_NAME = "processors";
    private static final String CONSUMER_NAME = "consumer-1";
    
    public static void main(String[] args) {
        // 连接Redis
        Jedis jedis = new Jedis("localhost", 6379);
        
        try {
            // 创建消费者组（如果不存在）
            try {
                jedis.xgroupCreate(STREAM_NAME, GROUP_NAME, StreamEntryID.LAST_ENTRY, true);
            } catch (Exception e) {
                // 组已存在，忽略
            }
            
            // 消费消息
            while (true) {
                Map<String, StreamEntryID> streams = new java.util.HashMap<>();
                streams.put(STREAM_NAME, StreamEntryID.UNRECEIVED_ENTRY);
                
                List<Map.Entry<String, List<StreamEntry>>> messages = jedis.xreadGroup(
                    GROUP_NAME,
                    CONSUMER_NAME,
                    XReadGroupParams.xReadGroupParams().count(10).block(1000),
                    streams
                );
                
                if (messages != null && !messages.isEmpty()) {
                    for (Map.Entry<String, List<StreamEntry>> entry : messages) {
                        for (StreamEntry message : entry.getValue()) {
                            System.out.println("Received: " + message.getID() + " - " + message.getFields());
                            
                            // 处理消息
                            // processOrder(message.getFields());
                            
                            // 确认消息
                            jedis.xack(STREAM_NAME, GROUP_NAME, message.getID());
                        }
                    }
                }
            }
        } catch (InterruptedException e) {
            System.out.println("Consumer stopped");
        } finally {
            jedis.close();
        }
    }
}
