# TC-MQTT-C-ORD-01：C 客户端的 MQTT 顺序性 用例

> **维度**：系统=MQTT | 语言=C | 特性=ORD(顺序性) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 顺序性格
> **环境**：E2 docker；**状态**：pending

## Given
- 有序通道；QoS1 重可致重复

## When
- 网络乱序

## Then
- 通道有序重复可见（◐）
- 等级依据：TEST-C2 MQTT×顺序性=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/c/顺序性/TC-MQTT-C-ORD-01.sh   # 计划打印（挂账）
```

## 关联
- 01-64
