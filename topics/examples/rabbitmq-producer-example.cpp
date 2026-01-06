// RabbitMQ Producer示例 (C++)
// 依赖: SimpleAmqpClient

#include <SimpleAmqpClient/SimpleAmqpClient.h>
#include <iostream>
#include <string>
#include <sstream>

using namespace AmqpClient;

int main() {
    try {
        // 连接RabbitMQ
        Channel::ptr_t channel = Channel::Create("localhost", 5672, "guest", "guest");

        // 声明Exchange
        channel->DeclareExchange("order_exchange", Channel::EXCHANGE_TYPE_DIRECT, false, true);

        // 声明Queue
        channel->DeclareQueue("order_queue", false, true);

        // 绑定Queue到Exchange
        channel->BindQueue("order_queue", "order_exchange", "order.created");

        // 发送消息
        for (int i = 0; i < 10; i++) {
            std::ostringstream oss;
            oss << R"({"order_id":"ORD-)" << std::setfill('0') << std::setw(4) << i
                << R"(","user_id":"USER-)" << i
                << R"(","amount":)" << (100.0 + i) << "}";

            BasicMessage::ptr_t message = BasicMessage::Create(oss.str());
            message->DeliveryMode(BasicMessage::dm_persistent);

            channel->BasicPublish("order_exchange", "order.created", message);

            std::cout << "Sent: ORD-" << std::setfill('0') << std::setw(4) << i << std::endl;
        }

        std::cout << "Messages sent successfully" << std::endl;
    } catch (const std::exception &e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
