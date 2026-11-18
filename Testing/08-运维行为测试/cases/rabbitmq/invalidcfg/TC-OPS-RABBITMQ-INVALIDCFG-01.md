# TC-OPS-RABBITMQ-INVALIDCFG-01：RABBITMQ 非法配置拒绝 运维行为测试

> **维度**：系统=RABBITMQ | 行为=INVALIDCFG（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 非法 config

## When

- 启动

## Then

- 拒绝+行号提示

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/invalidcfg/TC-OPS-RABBITMQ-INVALIDCFG-01.sh   # 计划打印（挂账）
```

## 关联

- 03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
