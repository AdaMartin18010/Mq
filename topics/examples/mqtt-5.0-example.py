#!/usr/bin/env python3
"""
MQTT 5.0新特性示例
演示MQTT 5.0的User Properties、Shared Subscriptions等新特性
"""

import paho.mqtt.client as mqtt
import json
import time

# MQTT Broker配置
BROKER_HOST = 'localhost'
BROKER_PORT = 1883

def on_connect(client, userdata, flags, rc, properties=None):
    """连接回调"""
    if rc == 0:
        print("Connected to MQTT Broker")
        # 使用共享订阅
        client.subscribe("$share/group1/sensors/temperature")
    else:
        print(f"Failed to connect, return code {rc}")

def on_message(client, userdata, msg):
    """消息回调"""
    print(f"Received: {msg.topic} - {msg.payload.decode()}")
    if msg.properties:
        print(f"User Properties: {msg.properties.user_property}")

def mqtt_5_example():
    """MQTT 5.0示例"""
    # 创建MQTT 5.0客户端
    client = mqtt.Client(protocol=mqtt.MQTTv5)
    
    client.on_connect = on_connect
    client.on_message = on_message
    
    # 连接Broker
    client.connect(BROKER_HOST, BROKER_PORT, 60)
    
    # 发布消息，使用User Properties
    for i in range(10):
        message = {
            'sensor_id': f'sensor-{i}',
            'temperature': 25.0 + i,
            'timestamp': time.time()
        }
        
        client.publish(
            "sensors/temperature",
            payload=json.dumps(message),
            qos=1,
            properties=mqtt.Properties(
                user_property=[
                    ("trace-id", f"trace-{i}"),
                    ("priority", "high")
                ],
                message_expiry_interval=3600  # 1小时过期
            )
        )
        print(f"Published: {message['sensor_id']}")
        time.sleep(1)
    
    # 保持连接
    client.loop_forever()

if __name__ == '__main__':
    mqtt_5_example()
