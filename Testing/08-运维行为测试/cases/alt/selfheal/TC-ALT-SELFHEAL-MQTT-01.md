# TC-ALT-SELFHEAL-MQTT-01：自愈闭环 E2E — MQTT broker kill → 持久会话恢复

> **维度**：domain=ALT | subcat=SELFHEAL | code=MQTT | 断言面：CLI/admin/metrics/Prometheus/Alertmanager
> **行为依据**：01-64,03-68
> **环境**：E2 docker/k8s + 合成指标/故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- cleanSession=false / 持久会话

## When

- kill broker

## Then

- 客户端自动重连
- 持久会话恢复
- QoS1/2 消息补传

## 问题闭环（TEST-16 三模板）

- 问题报告单：记录故障注入时间、检测延迟、动作触发时间（模板 A）
- 修复/复盘单：P0/P1 必填，回流至 `Testing/05-体系与机制/cases/YYYY-MM-<slug>.md`（模板 C）
- registry 状态流转：pending → verified / quarantined（按 TEST-13 漂移机制）

> 模板来源：Testing/05-体系与机制/TEST-16-hermes执行规划与问题闭环.md §T.16.3 三模板

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/alt/selfheal/TC-ALT-SELFHEAL-MQTT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-64,03-68；与 08-运维行为测试 OPS 域互补，与 04-07 控制回路理论锚呼应
