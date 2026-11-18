# TC-CLU-MQTT-FORCE-EXIT-01：MQTT 集群节点强制退出

> **维度**：系统=MQTT | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-64/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 EMQX

## When

- kill -9 1 node

## Then

- 剩余节点接管会话
- cleanSession=false 客户端重连后恢复订阅
- QoS1/2 未确认消息补发

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/mqtt/force-exit/TC-CLU-MQTT-FORCE-EXIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
