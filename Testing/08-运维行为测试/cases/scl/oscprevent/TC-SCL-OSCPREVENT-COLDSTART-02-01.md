# TC-SCL-OSCPREVENT-COLDSTART-02-01：振荡防控 — 分批滚动预热防止雪崩

> **维度**：domain=SCL | subcat=OSCPREVENT | code=COLDSTART-02 | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：04-07
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 分 3 批扩容 / 每批预热

## When

- lag 逐步下降

## Then

- 每批启动后预热完成再下一批
- 无存储请求风暴
- 总 RTO 可接受

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/scl/oscprevent/TC-SCL-OSCPREVENT-COLDSTART-02-01.sh   # 计划打印（挂账）
```

## 关联

- 04-07；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
