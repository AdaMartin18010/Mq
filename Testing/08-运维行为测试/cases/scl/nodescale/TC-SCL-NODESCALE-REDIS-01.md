# TC-SCL-NODESCALE-REDIS-01：节点伸缩 — Redis Cluster 加节点 resharding

> **维度**：domain=SCL | subcat=NODESCALE | code=REDIS-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-67,03-67
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 master / 持续写入

## When

- redis-cli --cluster add-node + reshard

## Then

- slot 迁移进度可观测（cluster nodes）
- keys 迁移后一致
- 客户端 moved/ask 响应正确

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/nodescale/TC-SCL-NODESCALE-REDIS-01.sh   # 计划打印（挂账）
```

## 关联

- 01-67,03-67；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
