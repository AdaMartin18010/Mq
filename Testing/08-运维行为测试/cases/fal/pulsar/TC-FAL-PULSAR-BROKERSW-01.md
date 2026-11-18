# TC-FAL-PULSAR-BROKERSW-01：PULSAR broker 切换 运维行为测试

> **维度**：系统=PULSAR | 域=FAL（broker 切换）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.1 Broker 无状态化 / §1.62.7 故障推演
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- topic owner broker 进程 kill -9

## When
- producer/consumer 持续读写

## Then
- bundle ownership 在 metadata store 超时后释放，新 broker 获取 ownership，RTO≤10s【估算】
- 客户端 lookup 重定向成功，TCP 重连后无消息丢失
- 脑裂防护：ownership 由 ZooKeeper/Oxia EPHEMERAL 节点仲裁；旧 owner 会话失效后无法继续服务
- 数据一致性：消息持久在 BookKeeper，切换不丢已 ack 消息

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/fal/pulsar/TC-FAL-PULSAR-BROKERSW-01.sh   # 计划打印（挂账）
```

## 关联
- 01-62 §1.62.1 Broker 无状态化 / §1.62.7 故障推演；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
