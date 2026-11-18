# TC-NATS-TS-IDM-01：TS 客户端的 NATS 幂等去重 用例

> **维度**：系统=NATS | 语言=TS | 特性=IDM(幂等去重) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 幂等去重格
> **环境**：E2 docker；**状态**：pending

## Given

- Msg-Id 去重窗口

## When

- 窗口内重复发布

## Then

- 仅首条持久化（ASE-005）
- 等级依据：TEST-C2 NATS×幂等去重=◐

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/ts/幂等去重/TC-NATS-TS-IDM-01.sh   # 计划打印（挂账）
```

## 关联

- 01-63
