# TC-KAFKA-RS-BCK-01：RS 客户端的 KAFKA 背压 用例

> **维度**：系统=KAFKA | 语言=RS | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given
- producer buffer.memory 满；consumer fetch 上限

## When
- 生产速率>消费速率

## Then
- producer 阻塞非报错（设计行为）
- fetch 限流生效
- 等级依据：TEST-C2 KAFKA×背压=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/kafka/rs/背压/TC-KAFKA-RS-BCK-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66
