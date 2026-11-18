# TC-PST-MQTT-CS1-Q2-01：cleanSession=true / QoS=2 重启

> **维度**：系统=MQTT | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64【定理】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 客户端 CONNECT Clean Start=1，发布/订阅 QoS2

## When

- broker restart

## Then

- 会话状态不保留
- 已 PUBCOMP 的 QoS2 消息不补发
- 未完成的 PUBREC/PUBREL 状态丢失

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/mqtt/cs1-q2/TC-PST-MQTT-CS1-Q2-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64【定理】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
