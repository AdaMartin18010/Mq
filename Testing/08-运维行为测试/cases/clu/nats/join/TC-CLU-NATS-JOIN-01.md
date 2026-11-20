# TC-CLU-NATS-JOIN-01：NATS 集群路由发现

> **维度**：系统=NATS | 域=CLU | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66/03-09
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- 3 nats-server 配置 routes

## When

- 依次启动 server

## Then

- 每节点 nats-server 路由表显示 3 节点
- 客户端连接任意节点可发现全部
- cluster size=3

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/case-dryrun.sh TC-CLU-NATS-JOIN-01   # 计划打印（dry-run RC=0）
```

## 关联

- 01-66/03-09；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
