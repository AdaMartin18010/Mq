# TC-OPS-KAFKA-PAGECACHE-01：KAFKA 页缓存依赖 运维行为测试

> **维度**：系统=KAFKA | 行为=PAGECACHE（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- echo 3 > drop_caches

## When

- 冷读消费

## Then

- 读放大：冷段延迟上升
- 热段（active segment）不读页缓存

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/pagecache/TC-OPS-KAFKA-PAGECACHE-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
