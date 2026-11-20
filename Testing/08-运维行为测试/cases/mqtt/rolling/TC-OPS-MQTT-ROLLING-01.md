# TC-OPS-MQTT-ROLLING-01：MQTT 滚动重启 运维行为测试

> **维度**：系统=MQTT | 行为=ROLLING（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker 重启

## When

- 客户端

## Then

- 自动重连

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-MQTT-ROLLING-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
