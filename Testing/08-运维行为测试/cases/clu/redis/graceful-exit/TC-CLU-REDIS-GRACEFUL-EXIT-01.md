# TC-CLU-REDIS-GRACEFUL-EXIT-01：Redis Cluster 节点优雅退役

> **维度**：系统=REDIS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-67/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 主 3 从

## When

- redis-cli --cluster reshard 迁空 slots 后 shutdown

## Then

- 目标节点 slots=0
- reshard 过程中集群仍可用
- 客户端重定向到新的 slot owner

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/redis/graceful-exit/TC-CLU-REDIS-GRACEFUL-EXIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
