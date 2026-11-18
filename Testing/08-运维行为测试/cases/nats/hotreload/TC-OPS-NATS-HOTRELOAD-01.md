# TC-OPS-NATS-HOTRELOAD-01：NATS 配置热更新 运维行为测试

> **维度**：系统=NATS | 行为=HOTRELOAD（config 类）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：03-67
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- nats-server -sl reload

## When

- 配置热载

## Then

- 生效域对照 03-67（账户/权限热载）

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/nats/hotreload/TC-OPS-NATS-HOTRELOAD-01.sh   # 计划打印（挂账）
```

## 关联

- 03-67；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
