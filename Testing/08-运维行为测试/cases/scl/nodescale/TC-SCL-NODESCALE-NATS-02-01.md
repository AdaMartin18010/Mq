# TC-SCL-NODESCALE-NATS-02-01：节点伸缩 — NATS supercluster 网关节点加入

> **维度**：domain=SCL | subcat=NODESCALE | code=NATS-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-66
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- supercluster 两域

## When

- 新网关上线

## Then

- gateway 连接建立（/gatewayz）
- 跨域主题传播正常
- 无消息隔离

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-SCL-NODESCALE-NATS-02-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
