# TC-OPS-REDIS-ROLLING-01：REDIS 滚动重启 运维行为测试

> **维度**：系统=REDIS | 行为=ROLLING（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 主从切换重启

## When

- 服务连续

## Then

- failover 窗口

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/redis/rolling/TC-OPS-REDIS-ROLLING-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
