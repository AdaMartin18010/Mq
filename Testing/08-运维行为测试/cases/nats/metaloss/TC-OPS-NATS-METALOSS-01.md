# TC-OPS-NATS-METALOSS-01：NATS 元数据/控制器丢失 运维行为测试

> **维度**：系统=NATS | 行为=METALOSS（fault 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JetStream 元数据损坏

## When

- 重启

## Then

- 流重建+sequence 一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/metaloss/TC-OPS-NATS-METALOSS-01.sh   # 计划打印（挂账）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
