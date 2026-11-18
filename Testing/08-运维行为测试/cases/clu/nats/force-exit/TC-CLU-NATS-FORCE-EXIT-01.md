# TC-CLU-NATS-FORCE-EXIT-01：NATS 节点强制退出

> **维度**：系统=NATS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 JetStream R3

## When

- kill -9 1 server

## Then

- 剩余节点继续服务
- R3 stream 降级为 R2，仍可读可写
- 恢复后 re-elect 补全副本

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/nats/force-exit/TC-CLU-NATS-FORCE-EXIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
