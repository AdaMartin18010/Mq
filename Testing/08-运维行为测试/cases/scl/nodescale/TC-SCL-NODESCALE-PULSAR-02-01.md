# TC-SCL-NODESCALE-PULSAR-02-01：节点伸缩 — Pulsar bookie 扩容读路径均衡

> **维度**：domain=SCL | subcat=NODESCALE | code=PULSAR-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-62
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 消费冷数据

## When

- rereplication 完成后读

## Then

- 读请求分散到新 bookie
- pulsar_storage_read_rate 均衡
- 延迟无长尾

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/nodescale/TC-SCL-NODESCALE-PULSAR-02-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
