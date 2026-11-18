# TC-MQTT-PY-BCK-01：PY 客户端的 MQTT 背压 用例

> **维度**：系统=MQTT | 语言=PY | 特性=BCK(背压) | 转换链=T4
> **矩阵等级**：● native（正例断言）| **断言源**：TEST-C2 背压格
> **环境**：E2 docker；**状态**：pending

## Given
- Receive Maximum 流控

## When
- 慢订阅

## Then
- 窗口信用生效（01-64）
- 等级依据：TEST-C2 MQTT×背压=●

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/py/背压/TC-MQTT-PY-BCK-01.sh   # 计划打印（挂账）
```

## 关联
- ●
