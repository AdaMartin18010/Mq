/**
 * Kafka Consumer示例代码 (C++)
 *
 * 功能：演示Kafka Consumer的基本用法和最佳实践
 * 参考：[01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
 * 依赖：librdkafka (https://github.com/edenhill/librdkafka)
 */

#include <iostream>
#include <string>
#include <librdkafka/rdkafka.h>

class KafkaConsumerExample {
private:
    rd_kafka_t* consumer;
    rd_kafka_conf_t* conf;
    rd_kafka_topic_partition_list_t* topics;

public:
    KafkaConsumerExample(const std::string& brokers, const std::string& group_id) {
        // 创建配置对象
        conf = rd_kafka_conf_new();

        // 设置Broker地址和Group ID
        rd_kafka_conf_set(conf, "bootstrap.servers", brokers.c_str(), nullptr, 0);
        rd_kafka_conf_set(conf, "group.id", group_id.c_str(), nullptr, 0);

        // 消费配置（参考：01-04-形式化证明框架）
        rd_kafka_conf_set(conf, "enable.auto.commit", "false", nullptr, 0); // 手动提交offset
        rd_kafka_conf_set(conf, "auto.offset.reset", "earliest", nullptr, 0); // 从最早的消息开始消费

        // 性能优化配置（参考：01-06-架构设计深度分析）
        rd_kafka_conf_set(conf, "fetch.min.bytes", "1048576", nullptr, 0); // 1MB最小拉取量
        rd_kafka_conf_set(conf, "fetch.max.wait.ms", "500", nullptr, 0); // 最多等待500ms

        // 创建Consumer
        char errstr[512];
        consumer = rd_kafka_new(RD_KAFKA_CONSUMER, conf, errstr, sizeof(errstr));
        if (!consumer) {
            std::cerr << "创建Consumer失败: " << errstr << std::endl;
            exit(1);
        }
    }

    ~KafkaConsumerExample() {
        rd_kafka_topic_partition_list_destroy(topics);
        rd_kafka_destroy(consumer);
    }

    void subscribe(const std::string& topic) {
        topics = rd_kafka_topic_partition_list_new(1);
        rd_kafka_topic_partition_list_add(topics, topic.c_str(), RD_KAFKA_PARTITION_UA);

        rd_kafka_resp_err_t err = rd_kafka_subscribe(consumer, topics);
        if (err) {
            std::cerr << "订阅主题失败: " << rd_kafka_err2str(err) << std::endl;
            exit(1);
        }
        std::cout << "已订阅主题: " << topic << std::endl;
    }

    void consumeMessages() {
        while (true) {
            rd_kafka_message_t* msg = rd_kafka_consume(consumer, 1000); // 超时1秒

            if (!msg) {
                continue;
            }

            if (msg->err) {
                if (msg->err == RD_KAFKA_RESP_ERR__PARTITION_EOF) {
                    std::cout << "到达分区末尾" << std::endl;
                } else {
                    std::cerr << "消费消息失败: " << rd_kafka_message_errstr(msg) << std::endl;
                }
                rd_kafka_message_destroy(msg);
                continue;
            }

            // 处理消息
            std::string key((char*)msg->key, msg->key_len);
            std::string value((char*)msg->payload, msg->len);
            std::cout << "收到消息: topic=" << rd_kafka_topic_name(msg->rkt)
                      << ", partition=" << msg->partition
                      << ", offset=" << msg->offset
                      << ", key=" << key
                      << ", value=" << value << std::endl;

            // 手动提交offset（参考：03-03-故障场景与恢复策略）
            rd_kafka_commit(consumer, nullptr, 0);

            rd_kafka_message_destroy(msg);
        }
    }
};

int main() {
    KafkaConsumerExample consumer("localhost:9092", "test-group");
    consumer.subscribe("test-topic");
    consumer.consumeMessages();
    return 0;
}
