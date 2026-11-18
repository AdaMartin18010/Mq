# TC-OPS-REDIS-QUOTA-01：REDIS 配额生效 运维行为测试

> **维度**：系统=REDIS | 行为=QUOTA（quota 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66/TEST-C2
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- （无配额——反向用例）

## When

- 超限

## Then

- 系统不承诺配额语义

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/redis/quota/TC-OPS-REDIS-QUOTA-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66/TEST-C2；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
