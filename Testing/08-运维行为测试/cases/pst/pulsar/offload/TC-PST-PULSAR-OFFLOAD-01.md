# TC-PST-PULSAR-OFFLOAD-01：Pulsar 分层存储 offload 持久化

> **维度**：系统=PULSAR | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.4
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- namespace 开启 offload 到 S3，closed ledger 满足阈值

## When

- kill -9 bookie 并删除本地 ledger 后读取历史消息

## Then

- offloaded ledger 从 S3 可读
- 本地删除不影响已 offload 数据
- 读路径回退到分层存储，延迟上升但数据完整

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-PST-PULSAR-OFFLOAD-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-62 §1.62.4；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
