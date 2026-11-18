# TC-PULSAR-TS-FLT-01：TS 客户端的 PULSAR 消息过滤 用例

> **维度**：系统=PULSAR | 语言=TS | 特性=FLT(消息过滤) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 消息过滤格
> **环境**：E2 docker；**状态**：pending

## Given
- subscription filtering

## When
- 过滤订阅

## Then
- 服务端过滤正确（◐）
- 等级依据：TEST-C2 PULSAR×消息过滤=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/ts/消息过滤/TC-PULSAR-TS-FLT-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2
