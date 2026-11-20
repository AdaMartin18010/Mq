# 08-运维行为测试：系统特性运维用例库

> **定位**（批次 121-123）：以 **broker/系统自身行为** 为主角的运维测试——故障行为/生命周期/资源/配置/恢复/限额 **+ 客户端运维行为**（再平衡期间生产/连接风暴/重连风暴/版本兼容）。与 07-集成矩阵互补（07=客户端×语义集成，08=系统×行为，断言走 CLI/admin/metrics，语言无关）。
> 行为依据：每用例的断言源锚定 [03-68 运行行为档案](../../topics/03-架构与运维实践/03-68-系统运行行为档案.md) 与 [03-67 画像](../../topics/03-架构与运维实践/03-67-六系统运维画像矩阵.md) 的对应节。
> 目录：`catalog/ops-behavior.tsv`（行为全集+适用矩阵）→ `cases/<系统>/<行为>/TC-OPS-<SYS>-<BEH>-01.md`；registry 域 OPS。

## 行为类别（7 类 25 项）

| 类别 | 行为码 | 说明 |
| ------ | -------- | ------ |
| 故障行为 | DISKFULL/DISKSLOW/NETPART/BROKERKILL/METALOSS/REPLICALOST | 磁盘满/慢/网络分区/进程宕/元数据丢失/副本失联 |
| 生命周期 | STARTSEQ/GRACEFUL/FORCEKILL/ROLLING | 启动序列/优雅停机/强杀恢复/滚动重启 |
| 资源 | MEMWATER/GCPRESS/PAGECACHE | 内存水位/GC 压力/页缓存依赖 |
| 配置 | HOTRELOAD/DYNCONFIG/INVALIDCFG | 热更新/动态配置域/非法配置拒绝 |
| 恢复 | METARESTORE/LOGREPAIR | 元数据恢复/日志修复 |
| 限额 | QUOTA/CONNLIMIT/MSGSIZE | 配额/连接数/消息大小上限 |
| 客户端运维 | REBALPRODUCE/CLIENTFLOOD/RECONNSTORM/CLIENTVERS | 再平衡期间生产/连接风暴/重连风暴/版本兼容 |

## 执行形态

- 默认 dry-run（打印注入与断言计划）；真实执行需用户在场（E2 docker + 故障注入工具）
- **统一 dry-run 运行器（批次171）**：`bash Testing/08-运维行为测试/cases/case-dryrun.sh <TC-ID>`——411 个用例共用，打印头部+Given/When/Then 计划后以 `RESULT: SKIP` + RC=0 结束；每用例 `## Dry-run 验证` 节锚定本运行器（411/411 实测 RC=0，见 results/2026-11-20/h3-case-dryrun-evidence.md）
- 与 Testing/06-混沌的映射：GAME DAY 注入脚本（TC-CHA）是"动作层"，08 用例是"断言层"——注入复用，断言在 08 登记
- 每用例结尾标注行为依据（03-68 节锚），保证知识→用例可追溯

---

**最后更新**: 2026-11-20（批次171：统一 dry-run 运行器 + 411 锚点重锚 + 注册表 79 行补齐）
