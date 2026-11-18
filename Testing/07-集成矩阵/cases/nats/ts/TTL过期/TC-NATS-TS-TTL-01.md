# TC-NATS-TS-TTL-01：TypeScript-JavaScript 客户端的 NATS JetStream TTL过期 用例骨架

> **维度**：系统=NATS | 语言=TS | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 TTL过期格
> **环境**：E2；**状态**：pending

## Given
- （骨架）fixtures compose 起 NATS JetStream；TS 客户端见 languages.tsv 代表客户端

## When
- （骨架）按 TTL过期 特性标准动作触发（充实批细化）

## Then
- 正例断言：承诺/模式/不承诺的行为可判定（GWT 充实挂账——逐批回填 ASE）
- 等级依据：TEST-C2 矩阵 NATS JetStream×TTL过期=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/ts/TTL过期/TC-NATS-TS-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- 维度定义源：features.tsv/TEST-C2；充实批回填真 GWT 后流转 mapped
