# TC-PST-MQTT-CS1-Q0-01：cleanSession=true / QoS=0 重启

> **维度**：系统=MQTT | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64 §1.64.2/1.64.3【定理】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 客户端 CONNECT Clean Start=1，订阅 QoS0

## When

- broker restart

## Then

- 会话不存在，订阅丢失
- QoS0 消息无持久化，全部丢失
- 丢窗=全部

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-MQTT-CS1-Q0-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-64 §1.64.2/1.64.3【定理】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
