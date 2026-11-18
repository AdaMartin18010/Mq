# TC-SCL-NODESCALE-PULSAR-01：节点伸缩 — Pulsar bookie 扩容后 ledger 再分布

> **维度**：domain=SCL | subcat=NODESCALE | code=PULSAR-01 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62,03-67
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 bookie / 持续写入

## When

- 启动第 4 bookie

## Then

- 新 bookie 开始接收新 ledger
- auditor 触发 rereplication
- 磁盘使用率差距缩小

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/nodescale/TC-SCL-NODESCALE-PULSAR-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62,03-67；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
