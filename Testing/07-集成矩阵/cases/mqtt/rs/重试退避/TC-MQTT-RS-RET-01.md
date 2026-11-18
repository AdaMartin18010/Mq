# TC-MQTT-RS-RET-01：RS 客户端的 MQTT 重试退避 用例

> **维度**：系统=MQTT | 语言=RS | 特性=RET(重试退避) | 转换链=T4
> **矩阵等级**：◐ config（配置启用后正例）| **断言源**：TEST-C2 重试退避格
> **环境**：E2 docker；**状态**：pending

## Given

- 重连即重试

## When

- 断连

## Then

- 重连行为断言
- 等级依据：TEST-C2 MQTT×重试退避=◐

## Dry-run 验证

```bash
bash Testing/07-集成矩阵/cases/mqtt/rs/重试退避/TC-MQTT-RS-RET-01.sh   # 计划打印（挂账）
```

## 关联

- ◐
