# TC-NATS-C-PST-01：C(C++) 客户端的 NATS JetStream 持久化 用例骨架

> **维度**：系统=NATS | 语言=C | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 持久化格
> **环境**：E2；**状态**：pending

## Given
- （骨架）fixtures compose 起 NATS JetStream；C 客户端见 languages.tsv 代表客户端

## When
- （骨架）按 持久化 特性标准动作触发（充实批细化）

## Then
- 配置启用后正例：承诺/模式/不承诺的行为可判定（GWT 充实挂账——逐批回填 ASE）
- 等级依据：TEST-C2 矩阵 NATS JetStream×持久化=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/c/持久化/TC-NATS-C-PST-01.sh   # 计划打印（挂账）
```

## 关联
- 维度定义源：features.tsv/TEST-C2；充实批回填真 GWT 后流转 mapped
