# TC-MQTT-GO-PST-01：GO 客户端的 MQTT 持久化 用例

> **维度**：系统=MQTT | 语言=GO | 特性=PST(持久化) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 持久化格
> **环境**：E2 docker；**状态**：pending

## Given
- broker 配置决定

## When
- 重启

## Then
- 持久会话+保留消息断言
- 等级依据：TEST-C2 MQTT×持久化=◐

## Dry-run 验证
```bash
bash Testing/07-集成矩阵/cases/mqtt/go/持久化/TC-MQTT-GO-PST-01.sh   # 计划打印（挂账）
```

## 关联
- ◐
