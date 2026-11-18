# TC-PULSAR-C-IDM-01：C 客户端的 PULSAR 幂等去重 用例

> **维度**：系统=PULSAR | 语言=C | 特性=IDM(幂等去重) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 幂等去重格
> **环境**：E2 docker；**状态**：pending

## Given
- broker deduplication 开关

## When
- 重复发布

## Then
- 去重生效（◐需开开关）
- 等级依据：TEST-C2 PULSAR×幂等去重=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/c/幂等去重/TC-PULSAR-C-IDM-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62
