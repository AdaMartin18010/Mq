/**
 * MQTT Client示例代码 (C)
 *
 * 功能：演示MQTT客户端的基本用法和最佳实践
 * 参考：[02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
 * 依赖：paho.mqtt.c (https://github.com/eclipse/paho.mqtt.c)
 * 编译：gcc -o mqtt-client mqtt-client-example.c -lpaho-mqtt3c
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "MQTTClient.h"

#define ADDRESS     "tcp://localhost:1883"
#define CLIENTID    "c-client"
#define TOPIC       "home/+/sensor/temperature"
#define QOS         1
#define TIMEOUT     10000L

volatile MQTTClient_deliveryToken deliveredtoken;

void delivered(void* context, MQTTClient_deliveryToken dt) {
    printf("消息已投递: token=%d\n", dt);
    deliveredtoken = dt;
}

int msgarrvd(void* context, char* topicName, int topicLen, MQTTClient_message* message) {
    printf("收到消息: topic=%s, payload=%.*s\n", topicName, (int)message->payloadlen, (char*)message->payload);
    MQTTClient_freeMessage(&message);
    MQTTClient_free(topicName);
    return 1;
}

void connlost(void* context, char* cause) {
    printf("连接断开: %s\n", cause);
}

int main(int argc, char* argv[]) {
    MQTTClient client;
    MQTTClient_connectOptions conn_opts = MQTTClient_connectOptions_initializer;
    MQTTClient_message pubmsg = MQTTClient_message_initializer;
    MQTTClient_deliveryToken token;
    int rc;

    // 创建客户端
    MQTTClient_create(&client, ADDRESS, CLIENTID, MQTTCLIENT_PERSISTENCE_NONE, NULL);

    // 设置回调函数
    MQTTClient_setCallbacks(client, NULL, connlost, msgarrvd, delivered);

    // 连接选项
    conn_opts.keepAliveInterval = 60;
    conn_opts.cleansession = 1;

    // 连接
    if ((rc = MQTTClient_connect(client, &conn_opts)) != MQTTCLIENT_SUCCESS) {
        printf("连接失败: %d\n", rc);
        return 1;
    }
    printf("MQTT连接成功\n");

    // 订阅主题
    MQTTClient_subscribe(client, TOPIC, QOS, &token);
    printf("已订阅主题: %s, QoS: %d\n", TOPIC, QOS);

    // 发布消息
    pubmsg.payload = "25.5";
    pubmsg.payloadlen = strlen(pubmsg.payload);
    pubmsg.qos = QOS;
    pubmsg.retained = 0;
    MQTTClient_publishMessage(client, "home/room1/sensor/temperature", &pubmsg, &token);
    printf("已发布消息: topic=home/room1/sensor/temperature, payload=%s\n", pubmsg.payload);

    // 等待消息
    sleep(5);

    // 断开连接
    MQTTClient_disconnect(client, 10000);
    MQTTClient_destroy(&client);

    return 0;
}
