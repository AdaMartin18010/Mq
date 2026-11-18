# TC-PULSAR-PY-DLV-01：PY 客户端的 交付语义 断言

> **维度**：系统=PULSAR | 语言=PY | 特性=DLV | 转换链=T4
> **环境**：E2 docker；**状态**：pending

## Given

- pulsar-client Python（挂账：版本 118 批入 languages.tsv 核实）

## When

- 生产+重启

## Then

- 持久化消息存活

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/pulsar/py/交付语义/TC-PULSAR-PY-DLV-01.sh   # 计划打印
```

## 关联

- 01-62
