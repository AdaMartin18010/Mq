# TC-PULSAR-PY-ORD-01：PY 客户端的 PULSAR 顺序性 用例

> **维度**：系统=PULSAR | 语言=PY | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given
- 分区有序；Key_Shared 键序

## When
- 键散列生产

## Then
- 键内有序跨键并行
- 等级依据：TEST-C2 PULSAR×顺序性=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/pulsar/py/顺序性/TC-PULSAR-PY-ORD-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62
