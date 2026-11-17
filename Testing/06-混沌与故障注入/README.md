# 混沌工程与故障注入（Testing/06 子目录）

> **定位**：批次 81。为批次 68 GAME DAY 与批次 69 动态系统测试提供工具链与执行脚本。
> 工具选型【论证】：网络分区用 Toxiproxy（进程级、compose 友好）；K8s 用 Chaos Mesh（E3 挂账）；进程/容器级用 docker pause/kill + hermes 工具链（已有）。

## 三场景注入矩阵（TC-CHA-01~03）

| 用例 | 注入 | 工具 | 观测断言 | 自愈级别 |
| ---- | ---- | ---- | ---- | ---- |
| TC-CHA-01 broker 僵死 | `docker pause <broker>` 90s | docker | 客户端超时/重连行为；恢复后无消息丢失（热路径） | L1（pause/unpause） |
| TC-CHA-02 网络分区 | Toxiproxy 断链 broker↔consumer | toxiproxy | 积压增长率 < 阈值【估算】；恢复后追平时间 | L1 |
| TC-CHA-03 磁盘慢/满 | `docker run --storage-opt` 或挂载延迟代理 | Linux 层 | ISR 收缩行为（01-61 推演表实测对照） | L2 |

## 执行入口

```bash
# dry-run（默认）：打印注入步骤
bash Testing/06-混沌与故障注入/game-day.sh
# 真实注入（用户在场）
bash Testing/06-混沌与故障注入/game-day.sh --live TC-CHA-01
```

脚本行为：注入 → `hermes-diagnose.sh` 打标签 → 观测窗口 → 断言核对 → `hermes-collect-failbundle.sh` 归档（失败时）→ audit log 记录（L1 清理动作）。完整闭环见 [TEST-11](../00-规范与计划/TEST-11-hermes自治执行与自愈排障体系.md)。

## 挂账

- Toxiproxy 首次拉取与 Chaos Mesh（E3）随真实执行批次；
- Jepsen 风格线性探针（history checker）评估中——Go/Rust 探针开发列入后续。

**最后更新**: 2026-11-18
