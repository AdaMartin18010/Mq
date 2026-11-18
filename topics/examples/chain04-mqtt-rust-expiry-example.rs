// 链#4（01-82）：MQTT messageExpiryInterval → rumqttc → 应用层兜底 映射示例（断点#2 补偿）
// 对应矩阵用例：TC-MQTT-RS-TTL-01（ASE-012：过期消息不投递【定理】）
// 断点：rumqttc 不直接暴露 expiry——需应用层信封兜底（01-82 断点#2 补偿模式）

use rumqttc::{MqttOptions, Client, QoS};
use std::time::Duration;

fn main() {
    let mut opts = MqttOptions::new("tc-mqtt-rs", "localhost", 1883);
    opts.set_keep_alive(Duration::from_secs(60));
    let (mut client, _conn) = Client::new(opts, 10);

    // 补偿模式：信封内嵌 expires_at（契约兜底——schema 加字段，见 01-84 时间语义模式）
    let payload = r#"{"metric":"temperature","value":21.5,"expires_at":1763443200}"#;
    client.publish("sensors/site1/dev1/telemetry", QoS::AtLeastOnce, false, payload)
        .expect("publish");

    // 对账点：v5 expiry 语义 vs 应用层字段——消费端必须双重检查（XLAN-B 语义对等）
}
