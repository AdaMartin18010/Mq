# Testing 测试验证与修正

> **本文档定位**：本目录是项目的可执行测试验证体系——测试用例库（部署/集成/集群）、失败纠正与修正机制、以及知识库与运行环境的自我验证机制。与 02-43（测试设计论证）/03-59（测试操作指南）的关系：02-43 论证"为什么测"，03-59 给出"测试策略与通用方法"，本目录提供"可直接执行的用例编号、命令、预期输出与纠正流程"。

## 目录

- [Testing 测试验证与修正](#testing-测试验证与修正)
  - [目录](#目录)
  - [系列文档](#系列文档)
  - [用例编号规则](#用例编号规则)
  - [与现有资产的衔接](#与现有资产的衔接)
  - [快速开始](#快速开始)

---

## 系列文档

| 文件 | 内容 | 类型 |
| ------ | ------ | ------ |
| [TEST-01-测试体系总览与分层策略](TEST-01-测试体系总览与分层策略.md) | 五层测试金字塔、覆盖矩阵、权威基准锚点、质量门禁 | 设计/指南（180-290 行） |
| [TEST-02-运维部署测试用例](TEST-02-运维部署测试用例.md) | 安装/配置校验/升级回滚/备份恢复用例（TC-DEP-xx） | 设计/指南（180-290 行） |
| [TEST-03-集成测试用例](TEST-03-集成测试用例.md) | 契约/E2E/容器化/网络故障/多语言示例回归（TC-INT-xx） | 设计/指南（180-290 行） |
| [TEST-04-集群测试验证](TEST-04-集群测试验证.md) | 拓扑故障/一致性/混沌编排/恢复指标（TC-CLU-xx） | 设计/指南（180-290 行） |
| [TEST-05-测试纠正与修正机制](TEST-05-测试纠正与修正机制.md) | 失败分类学、隔离降级、根因分析、文档-测试同步修正 | 运维/指南（180-290 行） |
| [TEST-06-自我验证机制与脚本说明](TEST-06-自我验证机制与脚本说明.md) | doc-self-check.sh / mq-smoke-test.sh 说明与 CI 集成 | 运维/指南（180-290 行） |

## 用例编号规则

- 格式：`TC-<域>-<NN>`，域 = DEP（部署）/ INT（集成）/ CLU（集群）
- 每用例固定结构：目的 → 前置条件 → 步骤（命令）→ 预期输出 → 通过标准
- 用例与项目资产挂钩：docker-compose（config-templates/）、脚本（scripts/）、示例（examples/）

## 与现有资产的衔接

| 资产 | 在用例中的角色 |
| ------ | ---------------- |
| `config-templates/docker-compose-*.yml` | TEST-02 的部署目标环境（Kafka/NATS/RabbitMQ/All） |
| `scripts/deploy-*.sh`、`validate-config.sh`、`upgrade-check.sh`、`backup-verify.sh` | TEST-02 的执行器 |
| `scripts/benchmark.sh`、`message-test.sh`、`chaos-test.sh` | TEST-03/04 的执行器 |
| `examples/` 52 个多语言示例 | TEST-03 的回归对象 |
| Jepsen / KRaft TLA+（外部权威资产） | TEST-04 的一致性验证基准（引用而非自造，见 AGENTS.md §4.2） |

## 快速开始

```bash
# 1. 环境自检（无 docker 时自动跳过运行类用例）
./topics/scripts/mq-smoke-test.sh kafka

# 2. 文档/知识库规范自检
./topics/scripts/doc-self-check.sh quick

# 3. 全量自检（含密度抽样与技能漂移对账）
./topics/scripts/doc-self-check.sh full
```

---

**最后更新**: 2026-11-17
