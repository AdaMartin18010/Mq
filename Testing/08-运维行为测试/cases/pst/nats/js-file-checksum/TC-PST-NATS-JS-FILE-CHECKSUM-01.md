# TC-PST-NATS-JS-FILE-CHECKSUM-01：JetStream FileStore 校验

> **维度**：系统=NATS | 域=PST | 断言面：CLI/admin/metrics（语言无关）
> **行为依据**：01-66
> **环境**：E2 docker + 故障注入；**状态**：pending（真实执行=用户在场集中批）

## Given
- Stream 存储类型=file

## When
- 损坏一个 block 文件后重启

## Then
- 启动时 FileStore 校验和检测失败或跳过坏块
- 可从未损坏副本恢复（R>1）
- 单副本损坏需从备份恢复

## Dry-run 验证
```bash
bash Testing/08-运维行为测试/cases/pst/nats/js-file-checksum/TC-PST-NATS-JS-FILE-CHECKSUM-01.sh   # 计划打印（挂账）
```

## 关联
- 01-66；与 GAME DAY 关系：TC-CHA 为动作层，本用例为断言层
