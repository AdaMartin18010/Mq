# TC-NATS-RS-ORD-01：RS 客户端的 NATS 顺序性 用例

> **维度**：系统=NATS | 语言=RS | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given
- JetStream ordered consumer

## When
- 乱序注入

## Then
- 有序 consumer 序列断言（◐需 JetStream）
- 等级依据：TEST-C2 NATS×顺序性=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/nats/rs/顺序性/TC-NATS-RS-ORD-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66
