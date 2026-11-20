# TC-OPS-RABBITMQ-MEMWATER-01：RABBITMQ 内存水位 运维行为测试

> **维度**：系统=RABBITMQ | 行为=MEMWATER（resource 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68 资源模型
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 内存逼近 watermark（0.4 默认）

## When

- 发布

## Then

- connection/channel 阻塞行为
- 流控解除

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-OPS-RABBITMQ-MEMWATER-01   # 计划打印（dry-run RC=0）
```

## 关联

- 03-68 资源模型；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
