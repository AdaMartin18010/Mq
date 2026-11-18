# TC-OPS-RABBITMQ-ROLLING-01：RABBITMQ 滚动重启 运维行为测试

> **维度**：系统=RABBITMQ | 行为=ROLLING（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 逐节点重启

## When

- 生产连续

## Then

- 客户端重连成功
- 无队列不可用窗口

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/rolling/TC-OPS-RABBITMQ-ROLLING-01.sh   # 计划打印（挂账）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
