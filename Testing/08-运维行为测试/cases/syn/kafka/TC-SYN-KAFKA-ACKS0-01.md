# TC-SYN-KAFKA-ACKS0-01：KAFKA acks=0 行为 运维行为测试

> **维度**：系统=KAFKA | 域=SYN（acks=0 行为）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-61 §1.61.2 acks 语义 / 01-63 §1.63.1 交付语义
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- producer acks=0, retries=0

## When

- kill leader during send

## Then

- producer 不等待 ack，吞吐最高，故障时丢失未落盘消息（at-most-once）
- broker 侧无重试义务；不承诺持久化
- 行为符合 01-63 at-most-once 定义

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/kafka/TC-SYN-KAFKA-ACKS0-01.sh   # 计划打印（挂账）
```

## 关联

- 01-61 §1.61.2 acks 语义 / 01-63 §1.63.1 交付语义；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
