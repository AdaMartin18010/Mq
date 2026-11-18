# TC-ROCKETMQ-PY-IDM-01：Python 客户端的 RocketMQ 幂等去重 用例骨架

> **维度**：系统=ROCKETMQ | 语言=PY | 特性=IDM(幂等去重) | 转换链=T4
> **前置挂账**：TEST-C2 矩阵未覆盖该系统——待图谱补边后回填断言
> **环境**：E2；**状态**：pending

## Given
- （骨架）fixtures compose 起 RocketMQ；PY 客户端见 languages.tsv 代表客户端

## When
- （骨架）按 幂等去重 特性标准动作触发（充实批细化）

## Then
- （挂账）矩阵覆盖后回填断言

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rocketmq/py/幂等去重/TC-ROCKETMQ-PY-IDM-01.sh   # 计划打印（挂账）
```

## 关联
- 维度定义源：features.tsv/TEST-C2；充实批回填真 GWT 后流转 mapped
