// 链#3（01-82）：MQTT binding（operation 级 0.2.0）→ mqtt.js → mosquitto 配置 映射示例
// 对应矩阵用例：TC-MQTT-TS-DLV-01 / 05-iot-telemetry 场景
// 绑定声明: operations.<op>.bindings.mqtt.{qos,retain,messageExpiryInterval}（channel 级保留空！01-86 陷阱#8）
// 部署映射: config-templates/mqtt-broker-config.conf 的 listener/ACL

import mqtt from "mqtt";

const client = mqtt.connect("mqtt://localhost:1883", {
  protocolVersion: 5,             // v5 才有 messageExpiryInterval（01-64）
  properties: { receiveMaximum: 100 }, // 流控格 MQTT=◐：inflight 窗口
});

client.on("connect", () => {
  // binding qos:1 → 至少一次（交付语义格 MQTT=● 的协议基础【定理】）
  client.publish("sensors/site1/dev1/telemetry", '{"t":21.5}', {
    qos: 1,
    retain: false,
    properties: { messageExpiryInterval: 300 }, // binding messageExpiryInterval → v5 属性
  });
});

// 对账点：operation 级 binding（0.2.0）——写在 channel 级会被 binding-check 判违规
