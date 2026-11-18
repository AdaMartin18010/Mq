# TC-OPS-KAFKA-MSGSIZE-01：KAFKA 消息大小上限 运维行为测试

> **维度**：系统=KAFKA | 行为=MSGSIZE（quota 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-72 大小矩阵
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 发送 max.message.bytes+1 消息

## When

- 生产

## Then

- RecordTooLargeException+错误码
- 边界值（恰好=上限）通过

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/kafka/msgsize/TC-OPS-KAFKA-MSGSIZE-01.sh   # 计划打印（挂账）
```

## 关联

- 01-72 大小矩阵；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
