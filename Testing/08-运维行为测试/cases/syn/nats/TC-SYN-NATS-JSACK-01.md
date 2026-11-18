# TC-SYN-NATS-JSACK-01：NATS JetStream ack 同步点 运维行为测试

> **维度**：系统=NATS | 域=SYN（JetStream ack 同步点）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- JetStream 发布并等待 ack

## When

- stream 持久化后返回 ack

## Then

- 同步点：Publish 调用在消息写入 stream 且复制到多数副本后返回
- 支持 timeout / 重试
- 行为符合 01-63 NATS at-least-once

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/nats/TC-SYN-NATS-JSACK-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63 §1.63.7 NATS 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
