# TC-NATS-PY-BCK-01：Python 客户端的 NATS JetStream 背压 用例骨架

> **维度**：系统=NATS | 语言=PY | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 背压格
> **环境**：E2；**状态**：pending

## Given
- （骨架）fixtures compose 起 NATS JetStream；PY 客户端见 languages.tsv 代表客户端

## When
- （骨架）按 背压 特性标准动作触发（充实批细化）

## Then
- 正例断言：承诺/模式/不承诺的行为可判定（GWT 充实挂账——逐批回填 ASE）
- 等级依据：TEST-C2 矩阵 NATS JetStream×背压=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/py/背压/TC-NATS-PY-BCK-01.sh   # 计划打印（挂账）
```

## 关联
- 维度定义源：features.tsv/TEST-C2；充实批回填真 GWT 后流转 mapped
