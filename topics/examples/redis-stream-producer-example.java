package com.example.mq;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.StreamEntryID;
import java.util.HashMap;
import java.util.Map;

public class RedisStreamProducer {
    private static final String STREAM_NAME = "events:orders";
    
    public static void main(String[] args) {
        // 连接Redis
        Jedis jedis = new Jedis("localhost", 6379);
        
        try {
            // 发送消息
            for (int i = 0; i < 10; i++) {
                Map<String, String> fields = new HashMap<>();
                fields.put("order_id", String.format("ORD-%04d", i));
                fields.put("user_id", "USER-" + i);
                fields.put("amount", String.valueOf(100.0 + i));
                fields.put("timestamp", String.valueOf(System.currentTimeMillis()));
                
                // 添加消息到Stream
                StreamEntryID messageId = jedis.xadd(
                    STREAM_NAME,
                    StreamEntryID.NEW_ENTRY,
                    fields
                );
                
                System.out.println("Sent: " + messageId + " - ORD-" + String.format("%04d", i));
            }
            
            System.out.println("Messages sent successfully");
        } finally {
            jedis.close();
        }
    }
}
