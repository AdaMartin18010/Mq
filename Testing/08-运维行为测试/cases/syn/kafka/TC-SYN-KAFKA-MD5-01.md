# TC-SYN-KAFKA-MD5-01：KAFKA 副本内容一致性 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 复制协议 / §1.61.3 Leader Epoch
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- RF=3 同一分区写入固定消息集合

## When

- 从各 replica 导出同一段 segment

## Then

- 各 replica 同 offset 范围 payload md5 一致
- leader epoch sequence file 在各副本一致
- 差异 offset 若存在则落在未提交区间（< HW）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/kafka/TC-SYN-KAFKA-MD5-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2 复制协议 / §1.61.3 Leader Epoch；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
