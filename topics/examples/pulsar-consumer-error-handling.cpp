// Pulsar C++ Consumer容错异常处理示例
// 基于concept06.md和Pulsar官方文档

#include <pulsar/Client.h>
#include <pulsar/Consumer.h>
#include <pulsar/Message.h>
#include <pulsar/Result.h>
#include <iostream>
#include <thread>
#include <chrono>
#include <memory>

/// 带容错机制的Pulsar Consumer
class RobustPulsarConsumer {
private:
    pulsar::Client client_;
    pulsar::Consumer consumer_;
    pulsar::Producer dlq_producer_;  // 死信队列Producer

public:
    RobustPulsarConsumer(const std::string& service_url, 
                         const std::string& topic,
                         const std::string& subscription_name) {
        pulsar::ClientConfiguration client_config;
        client_config.setConnectionTimeout(10000);
        client_config.setOperationTimeout(30000);

        pulsar::Result result = client_.create(service_url, client_config);
        if (result != pulsar::ResultOk) {
            throw std::runtime_error("Failed to create client: " + result.str());
        }

        pulsar::ConsumerConfiguration consumer_config;
        consumer_config.setConsumerType(pulsar::ConsumerType::ConsumerShared);
        consumer_config.setAckTimeoutMs(30000);
        consumer_config.setNegativeAckRedeliveryDelayMs(60000);
        consumer_config.setReceiverQueueSize(1000);

        result = client_.subscribe(topic, subscription_name, consumer_config, consumer_);
        if (result != pulsar::ResultOk) {
            client_.close();
            throw std::runtime_error("Failed to create consumer: " + result.str());
        }

        // 创建死信队列Producer
        pulsar::ProducerConfiguration dlq_config;
        std::string dlq_topic = topic + "-dlq";
        result = client_.createProducer(dlq_topic, dlq_config, dlq_producer_);
        if (result != pulsar::ResultOk) {
            std::cerr << "Warning: Failed to create DLQ producer: " << result.str() << std::endl;
        }
    }

    /// 带异常处理的消息消费
    void consumeWithErrorHandling() {
        while (true) {
            pulsar::Message msg;
            pulsar::Result result = consumer_.receive(msg, 1000);  // 1秒超时

            if (result == pulsar::ResultOk) {
                // 处理消息
                if (processMessage(msg)) {
                    // 处理成功，确认消息
                    consumer_.acknowledge(msg);
                } else {
                    // 处理失败，判断是否可重试
                    if (isRetriableError()) {
                        // 可重试错误，否定确认（自动重试）
                        consumer_.negativeAcknowledge(msg);
                    } else {
                        // 不可重试错误，确认消息并发送到死信队列
                        consumer_.acknowledge(msg);
                        sendToDLQ(msg);
                    }
                }
            } else if (result == pulsar::ResultTimeout) {
                // 接收超时，继续
                continue;
            } else {
                // 其他错误
                std::cerr << "Receive error: " << result.str() << std::endl;
                handleConsumerError(result);
                std::this_thread::sleep_for(std::chrono::seconds(1));
            }
        }
    }

private:
    /// 处理消息
    bool processMessage(const pulsar::Message& msg) {
        // 业务逻辑处理
        std::string content = msg.getDataAsString();
        std::cout << "Processing message: " << content << std::endl;
        
        // 模拟处理失败
        // if (someCondition) {
        //     return false;
        // }
        
        return true;
    }

    /// 判断错误是否可重试
    bool isRetriableError() {
        // 临时错误可重试，永久错误不可重试
        return true;  // 简化示例
    }

    /// 发送到死信队列
    void sendToDLQ(const pulsar::Message& msg) {
        pulsar::Message dlq_msg = pulsar::MessageBuilder()
            .setContent(msg.getDataAsString())
            .setProperty("original_topic", msg.getTopicName())
            .setProperty("original_msg_id", msg.getMessageId().toString())
            .build();

        pulsar::Result result = dlq_producer_.send(dlq_msg);
        if (result == pulsar::ResultOk) {
            std::cout << "Message sent to DLQ: " << msg.getMessageId() << std::endl;
        } else {
            std::cerr << "Failed to send to DLQ: " << result.str() << std::endl;
        }
    }

    /// 处理Consumer错误
    void handleConsumerError(pulsar::Result result) {
        std::cerr << "Consumer error: " << result.str() << std::endl;
        // 可以在这里实现重连逻辑、告警等
    }

public:
    ~RobustPulsarConsumer() {
        dlq_producer_.close();
        consumer_.close();
        client_.close();
    }
};

int main() {
    try {
        RobustPulsarConsumer consumer(
            "pulsar://localhost:6650",
            "my-topic",
            "my-subscription"
        );

        consumer.consumeWithErrorHandling();
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
