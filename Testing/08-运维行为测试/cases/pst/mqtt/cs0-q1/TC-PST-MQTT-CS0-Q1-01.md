# TC-PST-MQTT-CS0-Q1-01：cleanSession=false / QoS=1 重启

> **维度**：系统=MQTT | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64【定理】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 客户端 CONNECT Clean Start=0 Session Expiry>0，发布/订阅 QoS1

## When

- broker restart

## Then

- 会话保留，未确认的 QoS1 消息在 Session Expiry 内补发
- 已 PUBACK 消息不重复
- 丢窗=0（在 Session Expiry 内）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/mqtt/cs0-q1/TC-PST-MQTT-CS0-Q1-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64【定理】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
