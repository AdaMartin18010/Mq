# TC-SYN-NATS-SUPER-01：NATS supercluster 分区恢复 运维行为测试

> **维度**：系统=NATS | 域=SYN（supercluster 分区恢复）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-63 §1.63.7 NATS 语义对照
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- NATS supercluster 两个本地集群

## When
- gateway 链路分区后恢复

## Then
- 分区期间各本地集群独立服务
- 恢复后 interest 与 stream 状态同步
- 不超出 at-least-once 重复投递

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/syn/nats/TC-SYN-NATS-SUPER-01.sh   # 计划打印（挂账）
```

## 关联
- 01-63 §1.63.7 NATS 语义对照；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
