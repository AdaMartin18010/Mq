/**
 * Kafka Consumer示例代码 (C)
 *
 * 功能：演示Kafka Consumer的基本用法和最佳实践
 * 参考：[01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
 * 依赖：librdkafka (https://github.com/edenhill/librdkafka)
 * 编译：gcc -o kafka-consumer kafka-consumer-example.c -lrdkafka
 */

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <librdkafka/rdkafka.h>

static int run = 1;

static void stop(int sig) {
    run = 0;
}

int main() {
    rd_kafka_t* consumer;
    rd_kafka_conf_t* conf;
    rd_kafka_topic_partition_list_t* topics;
    char errstr[512];

    // 注册信号处理
    signal(SIGINT, stop);

    // 创建配置对象
    conf = rd_kafka_conf_new();

    // 设置Broker地址和Group ID
    rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092", errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "group.id", "test-group", errstr, sizeof(errstr));

    // 消费配置（参考：01-04-形式化证明框架）
    rd_kafka_conf_set(conf, "enable.auto.commit", "false", errstr, sizeof(errstr)); // 手动提交offset
    rd_kafka_conf_set(conf, "auto.offset.reset", "earliest", errstr, sizeof(errstr)); // 从最早的消息开始消费

    // 性能优化配置（参考：01-06-架构设计深度分析）
    rd_kafka_conf_set(conf, "fetch.min.bytes", "1048576", errstr, sizeof(errstr)); // 1MB最小拉取量
    rd_kafka_conf_set(conf, "fetch.max.wait.ms", "500", errstr, sizeof(errstr)); // 最多等待500ms

    // 创建Consumer
    consumer = rd_kafka_new(RD_KAFKA_CONSUMER, conf, errstr, sizeof(errstr));
    if (!consumer) {
        fprintf(stderr, "创建Consumer失败: %s\n", errstr);
        return 1;
    }

    // 订阅主题
    topics = rd_kafka_topic_partition_list_new(1);
    rd_kafka_topic_partition_list_add(topics, "test-topic", RD_KAFKA_PARTITION_UA);

    rd_kafka_resp_err_t err = rd_kafka_subscribe(consumer, topics);
    if (err) {
        fprintf(stderr, "订阅主题失败: %s\n", rd_kafka_err2str(err));
        rd_kafka_destroy(consumer);
        return 1;
    }

    printf("已订阅主题: test-topic\n");

    // 消费消息循环
    while (run) {
        rd_kafka_message_t* msg = rd_kafka_consume(consumer, 1000); // 超时1秒

        if (!msg) {
            continue;
        }

        if (msg->err) {
            if (msg->err == RD_KAFKA_RESP_ERR__PARTITION_EOF) {
                printf("到达分区末尾\n");
            } else {
                fprintf(stderr, "消费消息失败: %s\n", rd_kafka_message_errstr(msg));
            }
            rd_kafka_message_destroy(msg);
            continue;
        }

        // 处理消息
        printf("收到消息: topic=%s, partition=%d, offset=%lld, key=%.*s, value=%.*s\n",
               rd_kafka_topic_name(msg->rkt),
               msg->partition,
               msg->offset,
               (int)msg->key_len, (char*)msg->key,
               (int)msg->len, (char*)msg->payload);

        // 手动提交offset（参考：03-03-故障场景与恢复策略）
        rd_kafka_commit(consumer, NULL, 0);

        rd_kafka_message_destroy(msg);
    }

    // 清理资源
    rd_kafka_topic_partition_list_destroy(topics);
    rd_kafka_destroy(consumer);

    return 0;
}
