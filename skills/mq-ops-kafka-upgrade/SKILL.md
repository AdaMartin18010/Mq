---
name: mq-ops-kafka-upgrade
description: >
  Kafka 集群版本升级操作流程：升级前预检、滚动升级步骤、每步验证命令、
  回滚入口与检查清单，覆盖 3.x→4.x（ZooKeeper 移除）与 4.x 小版本场景。
  Use when Kafka 升级、版本升级、rolling upgrade、KRaft 迁移、
  kafka 版本回滚、升级失败处理、broker 升级步骤。
license: Apache-2.0
compatibility: Requires bash, kafka-topics.sh, kafka-broker-api-versions.sh, kafka-metadata-quorum.sh
metadata:
  source-doc: |
    topics/03-架构与运维实践/03-27-版本升级指南.md
    topics/01-基础概念与对比分析/01-25-Kafka-4.0新时代与队列语义分析.md
  derived-at: "2026-11-17"
  mq-system: kafka
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
  status: active
---

# Kafka 版本升级操作

## 适用范围
- 目标版本 Kafka 4.x（KRaft 模式；ZooKeeper 模式须先完成 KRaft 迁移，不在本技能范围）
- 集群规模 ≤ 50 broker（更大规模见源文档 03-27 的批次策略）
- 版本事实以 references/version-facts.md 为准（核实至 2026-01，执行前复核官方文档）

## 前置检查（全部通过才可继续）
- [ ] `kafka-broker-api-versions.sh --bootstrap-server <b> | grep 4.` 确认当前版本基线
- [ ] `kafka-topics.sh --describe --bootstrap-server <b>` 无 under-replicated partitions（非空先修复）
- [ ] 备份 `server.properties` 与 JMX 指标基线：`scripts/preflight-check.sh <bootstrap>`
- [ ] 确认回滚窗口：跨 major 版本（含 log format 前进）不支持直接回滚（见"回滚"节）

## 操作步骤
1. **升级 Controller（KRaft）**：替换二进制 → 滚动重启 controller → 验证：
   `kafka-metadata-quorum.sh describe --bootstrap-server <b>` 输出稳定 leader 且元数据版本前进。
2. ⚠️ **逐 broker 滚动**（一次一台，门控：上一台 URP=0）：
   ```bash
   ./kafka-server-stop.sh                 # 停流前确认副本已重分配止血
   # 替换二进制/镜像 tag
   ./kafka-server-start.sh config/server.properties
   ```
3. **每步验证**（不通过则停在该台排查）：
   ```bash
   kafka-topics.sh --describe --bootstrap-server <b> | grep -c "Leader: none"   # 预期 0
   kafka-topics.sh --describe --bootstrap-server <b> | grep -c "Under-replicated" # 预期 0
   kafka-consumer-groups.sh --describe --bootstrap-server <b> --all-groups | grep -c STUCK # 预期 0
   ```

## 回滚
- 同 major 内小版本降级：镜像 tag 回退 + 滚动重启（先回退 inter.broker.protocol.version 兼容位）。
- 跨 major（4.x→3.x）：**不支持直接回滚**（log format 前进）；只能走备份恢复。回滚窗口判断必须先于升级第一步。

## 边界与红线
- 不处理 ZooKeeper→KRaft 迁移（独立任务，见源文档 01-13/01-25）。
- 4.0 移除 ZooKeeper、4.1 引入 KIP-932 Share Groups（预览）为版本事实【论证：Kafka 官方发布说明，核实至 2026-01】，执行前以 Kafka 官方 upgrade 文档复核。
- 升级期间出现数据面异常（消息丢失/重复消费超阈值）立即中止并回退当前 broker。

## 参考
- references/version-facts.md（版本时间线与关键变更）
- scripts/preflight-check.sh（预检脚本）
- 源文档：topics/03-架构与运维实践/03-27-版本升级指南.md
