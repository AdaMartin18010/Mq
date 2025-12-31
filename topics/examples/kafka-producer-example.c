/**
 * Kafka Producer示例代码 (C)
 *
 * 功能：演示Kafka Producer的基本用法和最佳实践
 * 参考：[01-05-程序设计模式分析](../01-基础概念与对比分析/01-05-程序设计模式分析.md)
 * 依赖：librdkafka (https://github.com/edenhill/librdkafka)
 * 编译：gcc -o kafka-producer kafka-producer-example.c -lrdkafka
 */

#include <stdio.h>
#include <string.h>
#include <librdkafka/rdkafka.h>

int main() {
    rd_kafka_t* producer;
    rd_kafka_conf_t* conf;
    char errstr[512];

    // 创建配置对象
    conf = rd_kafka_conf_new();

    // 设置Broker地址
    rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092", errstr, sizeof(errstr));

    // 可靠性配置（参考：01-04-形式化证明框架）
    rd_kafka_conf_set(conf, "acks", "all", errstr, sizeof(errstr)); // 等待所有ISR副本确认
    rd_kafka_conf_set(conf, "retries", "3", errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "enable.idempotence", "true", errstr, sizeof(errstr)); // 启用幂等性

    // 性能优化配置（参考：01-06-架构设计深度分析）
    rd_kafka_conf_set(conf, "batch.size", "16384", errstr, sizeof(errstr)); // 16KB批量大小
    rd_kafka_conf_set(conf, "linger.ms", "10", errstr, sizeof(errstr)); // 等待10ms批量发送
    rd_kafka_conf_set(conf, "compression.type", "snappy", errstr, sizeof(errstr)); // 压缩算法

    // 创建Producer
    producer = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
    if (!producer) {
        fprintf(stderr, "创建Producer失败: %s\n", errstr);
        return 1;
    }

    // 发送消息
    const char* topic = "test-topic";
    const char* key = "user-123";
    const char* value = "{\"action\":\"login\"}";

    rd_kafka_resp_err_t err = rd_kafka_producev(
        producer,
        RD_KAFKA_V_TOPIC(topic),
        RD_KAFKA_V_KEY(key, strlen(key)),
        RD_KAFKA_V_VALUE(value, strlen(value)),
        RD_KAFKA_V_END
    );

    if (err) {
        fprintf(stderr, "发送消息失败: %s\n", rd_kafka_err2str(err));
    } else {
        printf("消息发送成功: topic=%s, key=%s\n", topic, key);
    }

    // 刷新缓冲区
    rd_kafka_flush(producer, 10000); // 等待10秒

    // 清理资源
    rd_kafka_destroy(producer);

    return 0;
}
