# TC-REDIS-RS-RET-01：Rust 客户端的 Redis Stream 重试退避 用例骨架

> **维度**：系统=REDIS | 语言=RS | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 重试退避格
> **环境**：E2；**状态**：pending

## Given
- （骨架）fixtures compose 起 Redis Stream；RS 客户端见 languages.tsv 代表客户端

## When
- （骨架）按 重试退避 特性标准动作触发（充实批细化）

## Then
- 应用层模式用例（契约兜底）：承诺/模式/不承诺的行为可判定（GWT 充实挂账——逐批回填 ASE）
- 等级依据：TEST-C2 矩阵 Redis Stream×重试退避=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/redis/rs/重试退避/TC-REDIS-RS-RET-01.sh   # 计划打印（挂账）
```

## 关联
- 维度定义源：features.tsv/TEST-C2；充实批回填真 GWT 后流转 mapped
