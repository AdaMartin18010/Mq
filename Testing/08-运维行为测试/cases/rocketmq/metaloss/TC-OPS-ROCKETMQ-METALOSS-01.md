# TC-OPS-ROCKETMQ-METALOSS-01：ROCKETMQ 元数据/控制器丢失 运维行为测试

> **维度**：系统=ROCKETMQ | 行为=METALOSS（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- kill namesrv

## When

- 路由

## Then

- 客户端路由缓存续用
- namesrv 重启恢复

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rocketmq/metaloss/TC-OPS-ROCKETMQ-METALOSS-01.sh   # 计划打印（挂账）
```

## 关联

- 【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
