/**
 * MQTT Client示例代码 (Go)
 *
 * 功能：演示MQTT客户端的基本用法和最佳实践
 * 参考：[02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
 * 依赖：go get github.com/eclipse/paho.mqtt.golang
 */

package main

import (
	"fmt"
	"log"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type MQTTClientExample struct {
	client mqtt.Client
}

func NewMQTTClient(broker string, port int, clientID string) *MQTTClientExample {
	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("tcp://%s:%d", broker, port))
	opts.SetClientID(clientID)

	// 连接配置
	opts.SetKeepAlive(60 * time.Second)
	opts.SetPingTimeout(10 * time.Second)
	opts.SetAutoReconnect(true)
	opts.SetMaxReconnectInterval(10 * time.Second)

	// 设置遗嘱消息（参考：02-01-场景化功能架构矩阵）
	opts.SetWill("home/device/status", `{"status":"offline"}`, 1, true)

	// 连接回调
	opts.OnConnect = func(client mqtt.Client) {
		log.Println("MQTT连接成功")
	}

	opts.OnConnectionLost = func(client mqtt.Client, err error) {
		log.Printf("MQTT连接断开: %v", err)
	}

	client := mqtt.NewClient(opts)
	return &MQTTClientExample{client: client}
}

func (c *MQTTClientExample) Connect() error {
	token := c.client.Connect()
	if token.Wait() && token.Error() != nil {
		return token.Error()
	}
	return nil
}

func (c *MQTTClientExample) Subscribe(topic string, qos byte, callback mqtt.MessageHandler) error {
	token := c.client.Subscribe(topic, qos, callback)
	if token.Wait() && token.Error() != nil {
		return token.Error()
	}
	log.Printf("已订阅主题: %s, QoS: %d", topic, qos)
	return nil
}

func (c *MQTTClientExample) Publish(topic string, qos byte, retained bool, payload string) error {
	token := c.client.Publish(topic, qos, retained, payload)
	if token.Wait() && token.Error() != nil {
		return token.Error()
	}
	log.Printf("已发布消息: topic=%s, payload=%s", topic, payload)
	return nil
}

func (c *MQTTClientExample) Disconnect() {
	c.client.Disconnect(250)
}

func main() {
	client := NewMQTTClient("localhost", 1883, "go-client")

	// 连接
	err := client.Connect()
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect()

	// 订阅主题（支持通配符）
	messageHandler := func(client mqtt.Client, msg mqtt.Message) {
		log.Printf("收到消息: topic=%s, payload=%s", msg.Topic(), string(msg.Payload()))
	}

	err = client.Subscribe("home/+/sensor/temperature", 1, messageHandler)
	if err != nil {
		log.Fatal(err)
	}

	// 发布消息
	err = client.Publish("home/room1/sensor/temperature", 1, false, "25.5")
	if err != nil {
		log.Fatal(err)
	}

	// 保持连接
	time.Sleep(5 * time.Second)
}
