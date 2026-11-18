# TC-KAFKA-PY-FLT-01：PY 客户端的 KAFKA 消息过滤 用例

> **维度**：系统=KAFKA | 语言=PY | 特性=FLT(消息过滤) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 消息过滤格
> **环境**：E2 docker；**状态**：pending

## Given
- 服务端过滤有限（客户端过滤为主）

## When
- 按条件消费

## Then
- 客户端过滤正确性
- 服务端 filter 挂账
- 等级依据：TEST-C2 KAFKA×消息过滤=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/py/消息过滤/TC-KAFKA-PY-FLT-01.sh   # 计划打印（挂账）
```

## 关联
- TEST-C2/02-13
