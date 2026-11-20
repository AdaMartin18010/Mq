# TC-SCL-NODESCALE-NATS-01：节点伸缩 — NATS 集群加节点路由收敛

> **维度**：domain=SCL | subcat=NODESCALE | code=NATS-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66,03-67
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 node cluster / 持续 sub/pub

## When

- 启动第 4 server

## Then

- server 加入 cluster 成功（/routez）
- interest 同步完成
- 客户端连接可路由到新节点

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-NODESCALE-NATS-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66,03-67；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
