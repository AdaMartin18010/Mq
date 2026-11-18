# TC-OPS-RABBITMQ-DISKFULL-01：RABBITMQ 磁盘满 运维行为测试

> **维度**：系统=RABBITMQ | 行为=DISKFULL（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68 故障
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 磁盘达到 disk_free_limit

## When

- 发布

## Then

- publisher 阻塞（alarm 行为）
- 清理后自动解除（03-68）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/diskfull/TC-OPS-RABBITMQ-DISKFULL-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68 故障；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
