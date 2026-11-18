# TC-CLU-NATS-HEAL-01：NATS 分区愈合后流状态收敛

> **维度**：系统=NATS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JetStream R3 分区后愈合

## When

- 检查 stream info 与 consumer sequence

## Then

- RAFT 日志合并，stream leader 唯一
- 消息顺序一致
- 无重复 sequence

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/nats/heal/TC-CLU-NATS-HEAL-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
