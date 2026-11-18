# TC-ROCKETMQ-PY-TTL-01：PY 客户端的 ROCKETMQ TTL过期 用例

> **维度**：系统=ROCKETMQ | 语言=PY | 特性=TTL(TTL过期) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 TTL过期格
> **环境**：E2 docker；**状态**：pending

## Given
- 保留期 7 天（无消息级 TTL）

## When
- 超期

## Then
- 清理可观测；消息级需应用层
- 等级依据：TEST-C2 ROCKETMQ×TTL过期=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/rocketmq/py/TTL过期/TC-ROCKETMQ-PY-TTL-01.sh   # 计划打印（挂账）
```

## 关联
- 【论证】
