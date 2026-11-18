# TC-MQTT-GO-IDM-01：GO 客户端的 MQTT 幂等去重 用例

> **维度**：系统=MQTT | 语言=GO | 特性=IDM(幂等去重) | 转换链=T4
> **矩阵等级**：○ app-level（应用层模式用例（契约兜底））| **断言源**：TEST-C2 幂等去重格
> **环境**：E2 docker；**状态**：pending

## Given
- 应用层

## When
- 重复发布

## Then
- 幂等键模式
- 等级依据：TEST-C2 MQTT×幂等去重=○

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/go/幂等去重/TC-MQTT-GO-IDM-01.sh   # 计划打印（挂账）
```

## 关联
- ○
