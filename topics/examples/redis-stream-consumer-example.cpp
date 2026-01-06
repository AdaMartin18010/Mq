// Redis Stream Consumer示例 (C++)
// 依赖: hiredis

#include <hiredis/hiredis.h>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

int main() {
    // 连接Redis
    redisContext *c = redisConnect("127.0.0.1", 6379);
    if (c == NULL || c->err) {
        if (c) {
            std::cerr << "Error: " << c->errstr << std::endl;
            redisFree(c);
        } else {
            std::cerr << "Error: Can't allocate redis context" << std::endl;
        }
        return 1;
    }

    std::string stream_name = "events:orders";
    std::string group_name = "processors";
    std::string consumer_name = "consumer-1";

    // 创建消费者组
    std::ostringstream create_group;
    create_group << "XGROUP CREATE " << stream_name << " " << group_name 
                 << " 0 MKSTREAM";
    redisReply *reply = (redisReply *)redisCommand(c, create_group.str().c_str());
    if (reply && reply->type == REDIS_REPLY_ERROR && 
        std::string(reply->str).find("BUSYGROUP") == std::string::npos) {
        std::cerr << "Error creating group: " << reply->str << std::endl;
    }
    if (reply) freeReplyObject(reply);

    // 消费消息
    while (true) {
        std::ostringstream read_group;
        read_group << "XREADGROUP GROUP " << group_name << " " << consumer_name
                   << " COUNT 10 BLOCK 1000 STREAMS " << stream_name << " >";

        reply = (redisReply *)redisCommand(c, read_group.str().c_str());
        
        if (reply == NULL) {
            std::cerr << "Error: " << c->errstr << std::endl;
            break;
        }

        if (reply->type == REDIS_REPLY_ARRAY && reply->elements > 0) {
            // 处理消息
            for (size_t i = 0; i < reply->elements; i++) {
                redisReply *stream = reply->element[i];
                if (stream->type == REDIS_REPLY_ARRAY && stream->elements >= 2) {
                    redisReply *messages = stream->element[1];
                    for (size_t j = 0; j < messages->elements; j++) {
                        redisReply *message = messages->element[j];
                        if (message->type == REDIS_REPLY_ARRAY && message->elements >= 2) {
                            std::cout << "Received: " << message->element[0]->str << std::endl;
                            
                            // 确认消息
                            std::ostringstream ack;
                            ack << "XACK " << stream_name << " " << group_name 
                                << " " << message->element[0]->str;
                            redisReply *ack_reply = (redisReply *)redisCommand(c, ack.str().c_str());
                            if (ack_reply) freeReplyObject(ack_reply);
                        }
                    }
                }
            }
        }

        if (reply) freeReplyObject(reply);
    }

    redisFree(c);
    return 0;
}
