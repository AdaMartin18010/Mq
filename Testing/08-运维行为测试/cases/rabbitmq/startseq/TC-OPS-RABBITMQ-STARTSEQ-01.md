# TC-OPS-RABBITMQ-STARTSEQ-01：RABBITMQ 启动序列 运维行为测试

> **维度**：系统=RABBITMQ | 行为=STARTSEQ（lifecycle 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-68 启动序列
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- compose 起

## When
- 就绪

## Then
- mnesia 表就绪先于 AMQP listener

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/rabbitmq/startseq/TC-OPS-RABBITMQ-STARTSEQ-01.sh   # 计划打印（挂账）
```

## 关联
- 03-68 启动序列；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
