# TC-CLU-NATS-GRACEFUL-EXIT-01：NATS 节点优雅退役

> **维度**：系统=NATS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66/03-68
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 节点 JetStream R3

## When

- nats-server  lame duck / 关闭

## Then

- 客户端路由表更新，新连接不再进入该节点
- R3 stream 重新选主
- 无消息丢失

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/clu/nats/graceful-exit/TC-CLU-NATS-GRACEFUL-EXIT-01.sh   # 计划打印（挂账）
```

## 关联

- 01-66/03-68；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
