# TC-OPS-KAFKA-CLIENTVERS-01：KAFKA 版本兼容 运维行为测试

> **维度**：系统=KAFKA | 行为=CLIENTVERS（clientops 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-71
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- librdkafka 旧版+4.x broker 混连

## When

- ApiVersions

## Then

- 协商降级成功（01-71 版本治理）
- KIP-896 floor 拒绝过旧客户端并明示

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-KAFKA-CLIENTVERS-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-71；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
