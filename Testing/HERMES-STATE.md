# HERMES-STATE：执行轨状态源（K6 §3.2）

> 唯一写者：hermes；主控梳理前必读。在域标记=当前正执行区域（主控规划避让依据）。

## 移交注记（主控 seeding——hermes 启动后可删本节）

**H1 起点状态**：Microcks 未就绪。mongo 4.4→7.0-jammy 升级失败（exit 62=**旧卷 featureCompatibility 不兼容**——microcks-mongo-data 卷仍持 4.4 格式数据）。
**H1 第一步**：`docker compose -f Testing/fixtures/docker-compose-microcks.yml down -v && up -d`（清旧卷重建），随后按 H1 判据推进（API 200→导入 01-order-lifecycle→contract test）。
**已就位**：镜像齐（microcks/mongo 7.0 已拉）；compose 已含 JAVA_OPTIONS mongo URI 修复。
**A2 已 verified（主控执行期）**：TC-SEM-05/07+Kafka 耐久，verified=23，详见 results/phase-A2-2026-11-18/。

## 当前在域

（空——H1 已闭环，批次169 提交后无在域）

## 队列进度（H1-H6）

| 项 | 状态 | 产物路径 | 完成时间 |
| ---- | ------ | ---------- | ---------- |
| H1 A3 Microcks 收尾 | ✅ 完成（批次169：4 spec 自包含导入+async-minion 接线+6/6 场景契约测试全绿 9/9 用例，根因链 4 项闭环） | results/2026-11-20/h1-microcks-evidence.md | 2026-11-20 |
| H2 冒烟资产修复 | ✅ 完成（批次167 六轮冒烟终验 PASS=3/FAIL=0/SKIP=1，2026-11-20） | results/2026-11-20/podman-migration-evidence.md §5 | 2026-11-20 |
| H3 GAME DAY+cases | 🟡 部分完成（批次171 dry-run 层：411/411 全绿+注册表 411/411+nats 17/17；`--live`=用户在场授权门挂起） | results/2026-11-20/h3-case-dryrun-evidence.md | 2026-11-20 |
| H4 基准首跑+L3 审批单 | 🟡 首跑完成（批次173：Kafka 实测基线稳态近 9.9k msg/s@1KB/acks=all；NATS/RabbitMQ blocked）；L3 审批单已出待签核 | results/2026-11-20/h4-benchmark-baseline.md + Testing/L3-审批单-H4基准转正-2026-11-20.md | 2026-11-20 |
| H5 周期常态化 | ⬜ | — | — |
| H6 SEC 复扫 | ✅ 完成（批次172：14 项基线复扫 14/0/0，对照批次127 基线零回退，RC=0） | results/2026-11-20/h6-sec-rescan-evidence.md | 2026-11-20 |

## 待上报 L3

| L3-审批单-H4基准转正-2026-11-20 | H4 Kafka 基线转正（A1）+ NATS 解锁（A2）+ RabbitMQ 解锁（A3）+ Kafka 3 节点拓扑修复（A4） | 待用户签核；未批准项维持挂起 | 2026-11-20 |

## 异常/漂移

（空）

---
**hermes 填写规范**：每 H 项完成更新本表+[EXEC] CHANGELOG；L3 立即列入待上报区并停线。
