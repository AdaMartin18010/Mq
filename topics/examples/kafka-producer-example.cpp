/**
 * Kafka Producer示例代码 (C++)
 *
 * 功能：演示Kafka Producer的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 * 依赖：librdkafka (https://github.com/edenhill/librdkafka)
 */

#include <iostream>
#include <string>
#include <librdkafka/rdkafka.h>

class KafkaProducerExample {
private:
    rd_kafka_t* producer;
    rd_kafka_conf_t* conf;

public:
    KafkaProducerExample(const std::string& brokers) {
        // 创建配置对象
        conf = rd_kafka_conf_new();

        // 设置Broker地址
        rd_kafka_conf_set(conf, "bootstrap.servers", brokers.c_str(), nullptr, 0);

        // 可靠性配置（参考：01-04-形式化证明框架）
        rd_kafka_conf_set(conf, "acks", "all", nullptr, 0); // 等待所有ISR副本确认
        rd_kafka_conf_set(conf, "retries", "3", nullptr, 0);
        rd_kafka_conf_set(conf, "enable.idempotence", "true", nullptr, 0); // 启用幂等性

        // 性能优化配置（参考：01-06-架构设计深度分析）
        rd_kafka_conf_set(conf, "batch.size", "16384", nullptr, 0); // 16KB批量大小
        rd_kafka_conf_set(conf, "linger.ms", "10", nullptr, 0); // 等待10ms批量发送
        rd_kafka_conf_set(conf, "compression.type", "snappy", nullptr, 0); // 压缩算法

        // 创建Producer
        char errstr[512];
        producer = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
        if (!producer) {
            std::cerr << "创建Producer失败: " << errstr << std::endl;
            exit(1);
        }
    }

    ~KafkaProducerExample() {
        rd_kafka_destroy(producer);
    }

    bool sendMessage(const std::string& topic, const std::string& key, const std::string& value) {
        // 创建消息
        rd_kafka_resp_err_t err;
        err = rd_kafka_producev(
            producer,
            RD_KAFKA_V_TOPIC(topic.c_str()),
            RD_KAFKA_V_KEY(key.c_str(), key.size()),
            RD_KAFKA_V_VALUE(value.c_str(), value.size()),
            RD_KAFKA_V_END
        );

        if (err) {
            std::cerr << "发送消息失败: " << rd_kafka_err2str(err) << std::endl;
            return false;
        }

        // 刷新缓冲区
        rd_kafka_poll(producer, 0);
        std::cout << "消息发送成功: topic=" << topic << ", key=" << key << std::endl;
        return true;
    }

    void flush() {
        rd_kafka_flush(producer, 10000); // 等待10秒
    }
};

int main() {
    KafkaProducerExample producer("localhost:9092");

    // 发送消息
    producer.sendMessage("test-topic", "user-123", R"({"action":"login"})");
    producer.sendMessage("test-topic", "user-456", R"({"action":"logout"})");

    // 刷新缓冲区
    producer.flush();

    return 0;
}
