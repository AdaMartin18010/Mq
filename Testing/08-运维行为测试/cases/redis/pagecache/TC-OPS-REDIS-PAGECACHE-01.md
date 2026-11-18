# TC-OPS-REDIS-PAGECACHE-01：REDIS 页缓存依赖 运维行为测试

> **维度**：系统=REDIS | 行为=PAGECACHE（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- drop_caches

## When
- AOF

## Then
- 重写/读取性能回退

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/redis/pagecache/TC-OPS-REDIS-PAGECACHE-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
