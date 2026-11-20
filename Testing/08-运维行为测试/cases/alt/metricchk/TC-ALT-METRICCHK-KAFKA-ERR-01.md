# TC-ALT-METRICCHK-KAFKA-ERR-01：指标正确性 — Kafka 错误率指标与客户端异常对拍

> **维度**：domain=ALT | subcat=METRICCHK | code=KAFKA-ERR | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-61,01-72
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 注入 RecordTooLarge / 超时

## When

- 对比 broker error 指标与客户端异常数

## Then

- 错误码一致
- 无静默失败
- metrics 标签含 error 类型

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-ALT-METRICCHK-KAFKA-ERR-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-61,01-72；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
