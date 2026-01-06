// RabbitMQ Consumer示例 (C++)
// 依赖: SimpleAmqpClient

#include <SimpleAmqpClient/SimpleAmqpClient.h>
#include <iostream>
#include <string>

using namespace AmqpClient;

int main() {
    try {
        // 连接RabbitMQ
        Channel::ptr_t channel = Channel::Create("localhost", 5672, "guest", "guest");

        // 声明Queue
        channel->DeclareQueue("order_queue", false, true);

        // 设置预取数量
        channel->BasicQos("order_queue", 1, false);

        // 消费消息
        std::string consumer_tag = channel->BasicConsume("order_queue", "", true, false, false);

        std::cout << "Waiting for messages. To exit press CTRL+C" << std::endl;

        while (true) {
            Envelope::ptr_t envelope = channel->BasicConsumeMessage(consumer_tag);
            
            std::string message = envelope->Message()->Body();
            std::cout << "Received: " << message << std::endl;

            // 处理消息
            // processOrder(message);

            // 确认消息
            channel->BasicAck(envelope);
        }
    } catch (const std::exception &e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
