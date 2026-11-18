# HERMES-STATE：执行轨状态源（K6 §3.2）

> 唯一写者：hermes；主控梳理前必读。在域标记=当前正执行区域（主控规划避让依据）。

## 移交注记（主控 seeding——hermes 启动后可删本节）

**H1 起点状态**：Microcks 未就绪。mongo 4.4→7.0-jammy 升级失败（exit 62=**旧卷 featureCompatibility 不兼容**——microcks-mongo-data 卷仍持 4.4 格式数据）。
**H1 第一步**：`docker compose -f Testing/fixtures/docker-compose-microcks.yml down -v && up -d`（清旧卷重建），随后按 H1 判据推进（API 200→导入 01-order-lifecycle→contract test）。
**已就位**：镜像齐（microcks/mongo 7.0 已拉）；compose 已含 JAVA_OPTIONS mongo URI 修复。
**A2 已 verified（主控执行期）**：TC-SEM-05/07+Kafka 耐久，verified=23，详见 results/phase-A2-2026-11-18/。

## 当前在域
（hermes 执行时填写，如：Testing/08/cases/nats/ — A4 GAME DAY 准备）

## 队列进度（H1-H6）
| 项 | 状态 | 产物路径 | 完成时间 |
|----|------|----------|----------|
| H1 A3 Microcks 收尾 | ⬜ 未开始 | — | — |
| H2 冒烟资产修复 | ⬜ | — | — |
| H3 GAME DAY+cases | ⬜ | — | — |
| H4 基准首跑+L3 审批单 | ⬜ | — | — |
| H5 周期常态化 | ⬜ | — | — |
| H6 SEC 复扫 | ⬜ | — | — |

## 待上报 L3
（空）

## 异常/漂移
（空）

---
**hermes 填写规范**：每 H 项完成更新本表+[EXEC] CHANGELOG；L3 立即列入待上报区并停线。
