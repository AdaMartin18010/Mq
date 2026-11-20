# TC-SYN-ROCKETMQ-MD5-01：ROCKETMQ 副本内容一致性 运维行为测试

> **维度**：系统=ROCKETMQ | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- master-slave 同步复制写入固定消息集合

## When

- 对比 commitlog 同 offset 段

## Then

- master 与 slave commitlog 同段 md5 一致（sync_flush/sync_master）
- consume queue offset 映射一致
- 异步模式下差异在可声明窗口内

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SYN-ROCKETMQ-MD5-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-63 §1.63.7 RocketMQ 语义对照 / 01-61 §1.61.2 复制协议（工程类比）；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
