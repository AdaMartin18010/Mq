# 05-iot-telemetry 语义标注

| 维度 | 为什么需要 | 涉及消息 | 验收关注点 |
| ---- | ---- | ---- | ---- |
| 交付语义 | 遥测/告警分级 | 全部 | QoS0 丢点合法、QoS1 告警必达【定理】（ASE-012 族） |
| TTL过期 | stale 数据无价值 | TelemetryReadingEvent | 离线重传超期消息被丢弃（消息过期 interval） |
| 流控 | 十万级设备并发 | 全部 | Receive Maximum/inflight 窗口生效（T.14 流控格） |
| 背压 | 采集洪峰（设备批量上线） | TelemetryReadingEvent | broker 内存水位与丢弃策略可观测 |

**设计陷阱**：

1. 遥测链路**禁止** QoS2——设备电量与带宽成本高于丢点代价（01-64 三 QoS 成本对照）。
2. collectedAt 用设备时钟，消费端必须容忍乱序与回拨（矩阵顺序性 ◐ 格）。

互链：[01-46 IoT 域标准](../../../../topics/01-基础概念与对比分析/01-46-IoT与互联网领域消息标准纵览.md)、[01-64 MQTT 全协议](../../../../topics/01-基础概念与对比分析/01-64-MQTT-5.0协议全解析.md)、config-templates/asyncapi-mqtt-example.yaml

**最后更新**: 2026-11-18
