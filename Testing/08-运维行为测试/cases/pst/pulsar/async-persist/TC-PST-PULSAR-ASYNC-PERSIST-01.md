# TC-PST-PULSAR-ASYNC-PERSIST-01：Pulsar 异步持久化 ACK

> **维度**：系统=PULSAR | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.3
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- producer 配置异步 ACK 或 send 不等待

## When

- kill broker

## Then

- 丢窗≤发送缓冲区内未确认批次
- broker 崩溃可能丢失尚未转存到 BookKeeper 的消息
- 异步 ACK 吞吐更高但丢窗更大

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/pulsar/async-persist/TC-PST-PULSAR-ASYNC-PERSIST-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.3；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
