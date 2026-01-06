// Redis Stream Producer示例 (C++)
// 依赖: hiredis

#include <hiredis/hiredis.h>
#include <iostream>
#include <string>
#include <sstream>
#include <ctime>

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

    // 发送消息
    for (int i = 0; i < 10; i++) {
        std::ostringstream oss;
        oss << "XADD " << stream_name << " * "
            << "order_id \"ORD-" << std::setfill('0') << std::setw(4) << i << "\" "
            << "user_id \"USER-" << i << "\" "
            << "amount \"" << (100.0 + i) << "\" "
            << "timestamp \"" << std::time(nullptr) << "\"";

        redisReply *reply = (redisReply *)redisCommand(c, oss.str().c_str());
        
        if (reply == NULL) {
            std::cerr << "Error: " << c->errstr << std::endl;
            redisFree(c);
            return 1;
        }

        if (reply->type == REDIS_REPLY_STRING) {
            std::cout << "Sent: " << reply->str << " - ORD-" 
                      << std::setfill('0') << std::setw(4) << i << std::endl;
        }

        freeReplyObject(reply);
    }

    redisFree(c);
    std::cout << "Messages sent successfully" << std::endl;
    return 0;
}
