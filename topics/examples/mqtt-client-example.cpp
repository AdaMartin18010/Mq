/**
 * MQTT Client示例代码 (C++)
 *
 * 功能：演示MQTT客户端的基本用法和最佳实践
 * 参考：[02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
 * 依赖：paho.mqtt.cpp (https://github.com/eclipse/paho.mqtt.cpp)
 */

#include <iostream>
#include <string>
#include <thread>
#include <chrono>
#include "mqtt/async_client.h"

class MQTTClientExample {
private:
    mqtt::async_client* client;
    mqtt::connect_options connOpts;

public:
    MQTTClientExample(const std::string& server_uri, const std::string& client_id)
        : client(new mqtt::async_client(server_uri, client_id)) {
        
        // 连接选项
        connOpts.set_keep_alive_interval(60);
        connOpts.set_clean_session(true);

        // 设置遗嘱消息（参考：02-01-场景化功能架构矩阵）
        mqtt::will_options will("home/device/status", R"({"status":"offline"})", 1, true);
        connOpts.set_will(will);

        // 设置连接回调
        client->set_connection_lost_handler([](const std::string& cause) {
            std::cout << "连接断开: " << cause << std::endl;
        });

        client->set_connected_handler([](const std::string& cause) {
            std::cout << "连接成功" << std::endl;
        });
    }

    ~MQTTClientExample() {
        delete client;
    }

    void connect() {
        try {
            client->connect(connOpts)->wait();
            std::cout << "MQTT连接成功" << std::endl;
        } catch (const mqtt::exception& exc) {
            std::cerr << "连接失败: " << exc.what() << std::endl;
        }
    }

    void subscribe(const std::string& topic, int qos) {
        try {
            client->subscribe(topic, qos)->wait();
            std::cout << "已订阅主题: " << topic << ", QoS: " << qos << std::endl;
        } catch (const mqtt::exception& exc) {
            std::cerr << "订阅失败: " << exc.what() << std::endl;
        }
    }

    void publish(const std::string& topic, const std::string& payload, int qos) {
        try {
            mqtt::message_ptr msg = mqtt::make_message(topic, payload);
            msg->set_qos(qos);
            client->publish(msg)->wait();
            std::cout << "已发布消息: topic=" << topic << ", payload=" << payload << std::endl;
        } catch (const mqtt::exception& exc) {
            std::cerr << "发布失败: " << exc.what() << std::endl;
        }
    }

    void disconnect() {
        client->disconnect()->wait();
    }
};

int main() {
    MQTTClientExample client("tcp://localhost:1883", "cpp-client");

    // 连接
    client.connect();

    // 设置消息回调
    client.subscribe("home/+/sensor/temperature", 1);

    // 发布消息
    client.publish("home/room1/sensor/temperature", "25.5", 1);

    // 保持连接
    std::this_thread::sleep_for(std::chrono::seconds(5));

    // 断开连接
    client.disconnect();

    return 0;
}
