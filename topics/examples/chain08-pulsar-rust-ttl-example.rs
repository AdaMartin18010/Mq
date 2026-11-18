// 链#8（01-82）：Pulsar binding（ttl/deduplication/namespace）→ pulsar-rs → broker 配置 映射示例
// 对应矩阵用例：TC-PULSAR-RS-TTL-01 / TC-PULSAR-RS-IDM-01
// 绑定声明: channels.*.bindings.pulsar.{namespace,persistence,ttl,deduplication}（0.1.0，必填 namespace/persistence）
// 断点#3：broker 开关（dedup/ttl）客户端无 API——部署模板联动核查（drift-check）

use pulsar::{Pulsar, TokioExecutor};
use pulsar::consumer::DeadLetterPolicy;

#[tokio::main]
async fn main() {
    let client: Pulsar<TokioExecutor> = Pulsar::builder("pulsar://localhost:6650")
        .build().await.unwrap();

    // 死信格 Pulsar=●：namespace 级 DLQ policy 经管理 API 配置（ASE-008 断言输入）
    let _dlp = DeadLetterPolicy {
        max_redeliver_count: 5,
        dead_letter_topic: "persistent://public/orders/orders-events-dlq".to_string(),
    };
    // TTL/去重在 broker 侧：pulsar-broker-config.conf 的 ttlSeconds/deduplication——
    // 客户端对账：admin API 回读（T3 链三层一致性的"部署层"落点）
}
