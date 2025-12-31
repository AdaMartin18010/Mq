"""
MQTT Client示例代码

功能：演示MQTT客户端的基本用法和最佳实践
参考：[02-03-程序设计模式场景化应用](../02-场景驱动架构设计/02-03-程序设计模式场景化应用.md)
"""

import paho.mqtt.client as mqtt
import time
import json

# MQTT Broker配置
BROKER_HOST = "localhost"
BROKER_PORT = 1883
CLIENT_ID = "python-client"
TOPIC = "home/+/sensor/temperature"

# QoS级别说明（参考：01-04-形式化证明框架）
# QoS 0: 最多一次，适合传感器数据
# QoS 1: 至少一次，适合控制指令
# QoS 2: 恰好一次，适合关键操作

class MQTTClient:
    def __init__(self):
        # 创建MQTT客户端
        self.client = mqtt.Client(client_id=CLIENT_ID)
        
        # 设置回调函数（观察者模式）
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message
        self.client.on_disconnect = self.on_disconnect
        
        # 设置遗嘱消息（参考：02-01-场景化功能架构矩阵）
        self.client.will_set(
            "home/device/status",
            json.dumps({"status": "offline", "client_id": CLIENT_ID}),
            qos=1,
            retain=True
        )
    
    def on_connect(self, client, userdata, flags, rc):
        """连接回调函数"""
        if rc == 0:
            print("连接成功")
            # 订阅主题（支持通配符）
            # + 单层通配符，如 home/+/sensor/temperature
            # # 多层通配符，如 home/#
            client.subscribe(TOPIC, qos=1)
        else:
            print(f"连接失败，错误码: {rc}")
    
    def on_message(self, client, userdata, msg):
        """消息接收回调函数"""
        topic = msg.topic
        payload = msg.payload.decode('utf-8')
        qos = msg.qos
        
        print(f"收到消息: topic={topic}, qos={qos}, payload={payload}")
        
        # 处理消息
        self.process_message(topic, payload)
    
    def on_disconnect(self, client, userdata, rc):
        """断开连接回调函数"""
        print("连接断开")
        # 实现指数退避重连（参考：03-03-故障场景与恢复策略）
        if rc != 0:
            self.reconnect_with_backoff()
    
    def process_message(self, topic, payload):
        """处理消息逻辑"""
        try:
            data = json.loads(payload)
            # 业务处理逻辑
            print(f"处理数据: {data}")
        except json.JSONDecodeError:
            print(f"消息格式错误: {payload}")
    
    def reconnect_with_backoff(self):
        """指数退避重连（避免重连风暴）"""
        max_retries = 5
        base_delay = 1  # 初始延迟1秒
        
        for attempt in range(max_retries):
            delay = base_delay * (2 ** attempt) + (time.random() * 0.1)  # 添加随机抖动
            print(f"等待 {delay} 秒后重连... (尝试 {attempt + 1}/{max_retries})")
            time.sleep(delay)
            
            try:
                self.client.reconnect()
                return
            except Exception as e:
                print(f"重连失败: {e}")
        
        print("重连失败，达到最大重试次数")
    
    def publish(self, topic, payload, qos=1):
        """发布消息"""
        result = self.client.publish(topic, payload, qos=qos)
        if result.rc == mqtt.MQTT_ERR_SUCCESS:
            print(f"消息发布成功: topic={topic}")
        else:
            print(f"消息发布失败: {result.rc}")
    
    def connect(self):
        """连接到Broker"""
        try:
            self.client.connect(BROKER_HOST, BROKER_PORT, keepalive=60)
            self.client.loop_start()  # 启动网络循环
        except Exception as e:
            print(f"连接异常: {e}")
    
    def disconnect(self):
        """断开连接"""
        self.client.loop_stop()
        self.client.disconnect()


# 使用示例
if __name__ == "__main__":
    client = MQTTClient()
    client.connect()
    
    try:
        # 发布消息示例
        time.sleep(2)  # 等待连接建立
        client.publish(
            "home/room1/sensor/temperature",
            json.dumps({"value": 25.5, "unit": "celsius"}),
            qos=1
        )
        
        # 保持运行
        time.sleep(60)
    finally:
        client.disconnect()

"""
最佳实践：
1. 使用QoS分级：传感器数据QoS0，控制指令QoS1，关键操作QoS2
2. 实现指数退避重连，避免重连风暴
3. 使用遗嘱消息（LWT）监控设备状态
4. 合理使用主题层级和通配符

参考文档：
- [01-04-形式化证明框架](../01-基础概念与对比分析/01-04-形式化证明框架.md)
- [02-01-场景化功能架构矩阵](../02-场景驱动架构设计/02-01-场景化功能架构矩阵.md)
- [03-03-故障场景与恢复策略](../03-架构与运维实践/03-03-故障场景与恢复策略.md)
"""
