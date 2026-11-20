# TC-FAL-MQTT-SESSION-01：MQTT broker 单点重启会话恢复 运维行为测试

> **维度**：系统=MQTT | 域=FAL（broker 单点重启会话恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.1 交付语义 / §1.63.7 MQTT 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- mosquitto 单节点，cleanSession=false 客户端连接并订阅 QoS1

## When
- kill broker 后重启

## Then
- 客户端无感重连，订阅与会话状态恢复
- 未 ack QoS1/2 消息按协议重投
- 脑裂防护：单点部署无分区双主；集群部署需外部共享存储/仲裁
- 数据一致性：持久会话文件 round-trip 后消息顺序一致

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-FAL-MQTT-SESSION-01   # 计划打印（dry-run RC=0）
```

## 关联
- 01-63 §1.63.1 交付语义 / §1.63.7 MQTT 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
