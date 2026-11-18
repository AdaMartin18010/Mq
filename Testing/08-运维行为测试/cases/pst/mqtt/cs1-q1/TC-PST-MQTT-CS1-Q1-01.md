# TC-PST-MQTT-CS1-Q1-01：cleanSession=true / QoS=1 重启

> **维度**：系统=MQTT | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64【定理】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- 客户端 CONNECT Clean Start=1，发布/订阅 QoS1

## When
- broker restart

## Then
- 会话状态不保留
- 已 PUBACK 的 QoS1 消息不补发
- 未确认 inflight 消息丢失

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/pst/mqtt/cs1-q1/TC-PST-MQTT-CS1-Q1-01.sh   # 计划打印（挂账）
```

## 关联
- 01-64【定理】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
