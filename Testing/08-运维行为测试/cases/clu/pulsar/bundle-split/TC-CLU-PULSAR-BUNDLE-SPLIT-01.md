# TC-CLU-PULSAR-BUNDLE-SPLIT-01：Pulsar Bundle 分裂与负载均衡

> **维度**：系统=PULSAR | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.1/1.62.6
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- namespace 单个 bundle 高负载

## When

- 触发 bundle split 或手动 unload

## Then

- bundle 分裂为两个 hash 区间
- 原 owner 断开客户端连接
- 新 topic 按 hash 落入新 bundle，ownership 重新竞争

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/pulsar/bundle-split/TC-CLU-PULSAR-BUNDLE-SPLIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.1/1.62.6；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
