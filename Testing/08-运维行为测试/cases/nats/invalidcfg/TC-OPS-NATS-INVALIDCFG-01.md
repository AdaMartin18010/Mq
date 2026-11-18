# TC-OPS-NATS-INVALIDCFG-01：NATS 非法配置拒绝 运维行为测试

> **维度**：系统=NATS | 行为=INVALIDCFG（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 非法 conf

## When

- 启动

## Then

- 校验拒绝+行号

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/invalidcfg/TC-OPS-NATS-INVALIDCFG-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
