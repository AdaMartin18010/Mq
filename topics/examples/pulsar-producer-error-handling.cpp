// Pulsar C++ Producer容错异常处理示例
// 基于concept06.md和Pulsar官方文档

#include <pulsar/Client.h>
#include <pulsar/Producer.h>
#include <pulsar/Message.h>
#include <pulsar/Result.h>
#include <iostream>
#include <thread>
#include <chrono>
#include <memory>

/// 重试配置
struct RetryConfig {
    int max_retries = 3;
    std::chrono::milliseconds initial_delay{1000};
};

/// 带容错机制的Pulsar Producer
class RobustPulsarProducer {
private:
    pulsar::Client client_;
    pulsar::Producer producer_;
    RetryConfig config_;

public:
    RobustPulsarProducer(const std::string& service_url, const std::string& topic)
        : config_({3, std::chrono::milliseconds(1000)}) {
        pulsar::ClientConfiguration client_config;
        client_config.setConnectionTimeout(10000);  // 10秒
        client_config.setOperationTimeout(30000);   // 30秒

        pulsar::Result result = client_.create(service_url, client_config);
        if (result != pulsar::ResultOk) {
            throw std::runtime_error("Failed to create client: " + result.str());
        }

        pulsar::ProducerConfiguration producer_config;
        producer_config.setSendTimeout(30000);           // 30秒
        producer_config.setMaxPendingMessages(1000);
        producer_config.setBlockIfQueueFull(true);      // 队列满时阻塞
        producer_config.setBatchingEnabled(true);
        producer_config.setBatchingMaxMessages(1000);
        producer_config.setBatchingMaxPublishDelayMs(10);

        result = client_.createProducer(topic, producer_config, producer_);
        if (result != pulsar::ResultOk) {
            client_.close();
            throw std::runtime_error("Failed to create producer: " + result.str());
        }
    }

    /// 带重试的发送
    pulsar::Result sendWithRetry(const std::string& message) {
        return sendWithRetry(message, config_);
    }

    /// 带自定义配置的重试发送
    pulsar::Result sendWithRetry(const std::string& message, const RetryConfig& config) {
        pulsar::Message msg = pulsar::MessageBuilder()
            .setContent(message)
            .build();

        pulsar::Result last_result = pulsar::ResultUnknownError;

        for (int attempt = 0; attempt < config.max_retries; ++attempt) {
            pulsar::Result result = producer_.send(msg);

            if (result == pulsar::ResultOk) {
                std::cout << "Message sent successfully" << std::endl;
                return pulsar::ResultOk;
            }

            last_result = result;

            // 判断是否可重试
            if (!isRetriable(result)) {
                return result;
            }

            if (attempt < config.max_retries - 1) {
                // 指数退避
                auto delay = config.initial_delay * (1 << attempt);
                std::cerr << "Retry attempt " << (attempt + 1) << "/" << config.max_retries
                          << " after " << delay.count() << "ms: " << result.str() << std::endl;
                std::this_thread::sleep_for(delay);
            }
        }

        return last_result;
    }

    /// 异步发送带回调
    void sendAsyncWithCallback(const std::string& message,
                               std::function<void(pulsar::Result, pulsar::MessageId)> callback) {
        pulsar::Message msg = pulsar::MessageBuilder()
            .setContent(message)
            .build();

        producer_.sendAsync(msg, [this, callback, message](pulsar::Result result, pulsar::MessageId msgId) {
            if (result != pulsar::ResultOk) {
                std::cerr << "Async send failed: " << result.str() << std::endl;
                // 可以在这里实现重试逻辑
                if (isRetriable(result)) {
                    // 重试
                    std::this_thread::sleep_for(config_.initial_delay);
                    sendAsyncWithCallback(message, callback);
                } else {
                    callback(result, msgId);
                }
            } else {
                callback(result, msgId);
            }
        });
    }

private:
    /// 判断错误是否可重试
    bool isRetriable(pulsar::Result result) {
        // 网络异常、超时异常可重试
        return result == pulsar::ResultTimeout ||
               result == pulsar::ResultConnectError ||
               result == pulsar::ResultNotConnected;
    }

public:
    ~RobustPulsarProducer() {
        producer_.close();
        client_.close();
    }
};

int main() {
    try {
        RobustPulsarProducer producer("pulsar://localhost:6650", "my-topic");

        // 同步发送带重试
        pulsar::Result result = producer.sendWithRetry("Hello Pulsar");
        if (result != pulsar::ResultOk) {
            std::cerr << "Send failed: " << result.str() << std::endl;
            return 1;
        }

        // 异步发送带回调
        producer.sendAsyncWithCallback("Hello Pulsar Async", 
            [](pulsar::Result result, pulsar::MessageId msgId) {
                if (result == pulsar::ResultOk) {
                    std::cout << "Async send succeeded: " << msgId << std::endl;
                } else {
                    std::cerr << "Async send failed: " << result.str() << std::endl;
                }
            });

        std::this_thread::sleep_for(std::chrono::seconds(2));
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
