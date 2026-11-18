# TC-NATS-TS-DEP-01：TypeScript-JavaScript 客户端的 NATS JetStream 部署形态 用例骨架

> **维度**：系统=NATS | 语言=TS | 特性=DEP(部署形态) | 转换链=T3,T4
> **依据**：03-67 部署形态画像
> **环境**：E2；**状态**：pending

## Given

- （骨架）fixtures compose 起 NATS JetStream；TS 客户端见 languages.tsv 代表客户端

## When

- （骨架）按 部署形态 特性标准动作触发（充实批细化）

## Then

- 运维特性断言（画像对标，逐批充实）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/ts/部署形态/TC-NATS-TS-DEP-01.sh   # 计划打印（挂账）
```

## 关联

- 维度定义源：features.tsv/03-67；充实批回填真 GWT 后流转 mapped
