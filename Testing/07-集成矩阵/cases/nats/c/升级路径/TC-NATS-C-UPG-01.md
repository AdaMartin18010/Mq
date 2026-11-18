# TC-NATS-C-UPG-01：C 客户端的 NATS 升级路径 用例

> **维度**：系统=NATS | 语言=C | 特性=UPG(升级路径) | 转换链=T3,T4
> **依据**：03-67/03-68 运维画像 | **环境**：E2；**状态**：pending

## Given

- 配置热重载

## When

- reload

## Then

- reload 信号生效（03-68）

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/nats/c/升级路径/TC-NATS-C-UPG-01.sh   # 计划打印（挂账）
```

## 关联

- 03-67
