# TC-SYN-NATS-MD5-01：NATS 副本内容一致性 运维行为测试

> **维度**：系统=NATS | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JetStream R3 stream 写入固定消息集合

## When

- 从 leader 与 replica 读取同 sequence

## Then

- 同 sequence 消息 payload md5 一致
- stream state 中 message count / bytes 一致
- consumer ack 状态一致性

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-NATS-MD5-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 NATS 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
