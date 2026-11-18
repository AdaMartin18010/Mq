# TC-PST-ROCKETMQ-ASYNC-FLUSH-01：RocketMQ ASYNC_FLUSH 断电丢窗

> **维度**：系统=ROCKETMQ | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68【论证】
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- broker flushDiskType=ASYNC_FLUSH

## When

- kill -9 broker 模拟断电

## Then

- 丢窗≤两次 flush 间隔（默认 500ms 或按 OS）
- 吞吐更高但存在落盘窗口
- 恢复后 commitlog 末尾可能截断

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/pst/rocketmq/async-flush/TC-PST-ROCKETMQ-ASYNC-FLUSH-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67/03-68【论证】；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
