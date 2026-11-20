# TC-SYN-REDIS-MD5-01：REDIS 副本内容一致性 运维行为测试

> **维度**：系统=REDIS | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 Redis Stream 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 主库写入固定 Stream entries

## When

- 在 replica 执行 XREAD 同 ID

## Then

- 同 ID entry payload md5 一致
- stream length / last-generated-id 一致
- consumer group PEL 一致

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-REDIS-MD5-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 Redis Stream 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
