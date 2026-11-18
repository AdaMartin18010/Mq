# TC-OPS-RABBITMQ-HOTRELOAD-01：RABBITMQ 配置热更新 运维行为测试

> **维度**：系统=RABBITMQ | 行为=HOTRELOAD（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- rabbitmq.conf 修改+reload

## When

- 生效域

## Then

- 热生效项对照 03-67
- listener 类需重启正确提示

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/rabbitmq/hotreload/TC-OPS-RABBITMQ-HOTRELOAD-01.sh   # 计划打印（挂账）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
