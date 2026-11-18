# TC-SYN-PULSAR-MD5-01：PULSAR 副本内容一致性 运维行为测试

> **维度**：系统=PULSAR | 域=SYN（副本内容一致性）| 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-62 §1.62.2 Ledger/Entry 结构 / §1.62.2 Ledger 恢复协议
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given

- E=3 写入固定 entry 集合

## When

- 从各 bookie 读取同 ledgerId:entryId

## Then

- entry 数据与校验和（crc）一致
- Lac 进度一致
- 差异 entry 若存在则位于未确认区间

## Dry-run 验证

```bash
bash Testing/08-运维行为测试/cases/syn/pulsar/TC-SYN-PULSAR-MD5-01.sh   # 计划打印（挂账）
```

## 关联

- 01-62 §1.62.2 Ledger/Entry 结构 / §1.62.2 Ledger 恢复协议；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
