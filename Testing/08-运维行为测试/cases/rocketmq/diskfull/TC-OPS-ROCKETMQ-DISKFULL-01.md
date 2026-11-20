# TC-OPS-ROCKETMQ-DISKFULL-01：ROCKETMQ 磁盘满 运维行为测试

> **维度**：系统=ROCKETMQ | 行为=DISKFULL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：【论证】03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- commitlog 磁盘满

## When

- 写入

## Then

- 刷盘失败行为
- 清理恢复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-ROCKETMQ-DISKFULL-01   # 计划打印（dry-run RC=0）
```

## 关联

- 【论证】03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
