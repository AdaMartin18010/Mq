# T.00 测试体系总规划（Testing 统一编排）

> **置信口径**: 机制设计=【论证】；工具行为以官方文档为准。
> **时效声明**: 核实至 2026-11-18（批次 105 重组后首版）。
> **本文档定位**: Testing 六子目录的唯一总规划——目录职责、用例域全景、验证要求分层、执行频率、产物规范、与 hermes 自治体系的边界。各子目录细节不重复，本表是入口。

## 一、目录职责总表

| 子目录 | 职责 | 关键资产 | 门禁 |
| ---- | ---- | ---- | ---- |
| `00-规范与计划/` | 体系规范：TEST-01 总览/TEST-08 映射矩阵/TEST-09 环境矩阵/TEST-10 编写规范/TEST-11 hermes 自治/TEST-12 企业用例 | 任务包生成规则、E0-E3 环境定义 | 变更须过 E0 registry 校验 |
| `01-部署用例/` | TC-DEP-xx：compose 部署/配置校验/冒烟 | fixtures compose 三系统 | E1/E2 冒烟 FAIL=0 |
| `02-集成用例/` | TC-INT-xx + TEST-12 企业场景：系统间集成行为 | schema-check/bridge-test/message-test 等 | weekly PASS≥95% |
| `03-集群用例/` | TC-CLU-xx：集群形态/容错/混沌（TEST-04 + 06-混沌与故障注入） | game-day.sh | 发布前关键集 0 FAIL |
| `04-可观测用例/` | TC-OBS-xx：指标/告警/OTel | prometheus 规则/keda 模板 | 规则加载成功 |
| `05-体系与机制/` | 治理机制：TEST-05 纠正/TEST-06 自验证/TEST-13 漂移/TEST-14 skill 回放/TEST-15 动态系统论视角 | warn-ledger/self-check-history | 月度回顾 |
| `06-契约语义测试/` | **契约与语义维度**（TEST-C1 总纲/C2 语义矩阵/C3 场景规范）：六层模型 specs/语义矩阵/场景包/行为用例/行为验证/追溯 | contract-spec-check/drift/binding/tc-assert/kg-query | E0 第 6-8 步 |
| `fixtures/` | 共享夹具：compose/测试数据/基准模板/**generators** | test-data-orders.json 等 | 生成器 --validate 全过 |

## 二、用例域全景（registry 14 域）

| 域 | 前缀 | 规模 | 验证层 |
| ---- | ---- | ---- | ---- |
| CHK 巡检 | CHK | 50 | E0 |
| DEP 部署 | TC-DEP | 24 | E1/E2 |
| INT 集成 | TC-INT + TC-XLAN | 25+6 | E2 |
| CLU 集群 | TC-CLU | 14 | E3 |
| OBS 可观测 | TC-OBS | 12 | E2/E3 |
| SEC 安全 | TC-SEC | 20 | E0 基线扫描 |
| CON 契约行为 | TC-CON | 5 | E1/E2（Microcks） |
| SEM 通信语义 | TC-SEM | 12 | E2（样例 2 就绪） |
| BUS 业务契约 | TC-BUS | 8 | E0 父用例 |
| SKL 技能回放 | TC-SKL | 21 | 人工/代理回放 |
| AIG AI 契约 | TC-AIG | 6 | E0 静态 |
| CHA 混沌 | TC-CHA | 3 | E2（GAME DAY） |
| DYN 动态系统 | TC-DYN | 4 | E2（RTO 趋势） |
| ABS 抽象层 | TC-ABS | 2 | E1（Dapr） |

## 三、验证要求分层（什么门禁在哪层）

```text
E0 每次提交（十四步）：doc-check / bash-n / registry / decision / spotcheck
                    / contract-spec / tc-assert / kg-check / consistency
                    / tc-design / spec-diff / spec-validate / secret-scan
                    / codeblock-check                                      ← 全自动
                    （批次181-198 逐步扩展；secret-scan=仓库机密泄露扫描 批次194；
                      codeblock-check=文档内嵌代码块语言标注+bash 语法 批次198）
E1/E2 夜间-周：容器冒烟+集成+契约行为（Microcks）+语义样例        ← hermes 周期
E3 发布前：集群关键集+混沌                                        ← 用户在场
真实执行集中批（挂账）：TC-SEM --live / GAME DAY / 基准首跑 / Microcks 首启
```

产物规范统一 T.09.5（五字段 JSON + 尾三行正则）；失败处置统一 TEST-11 L0-L3；状态机统一 TEST-13。

## 四、与相邻体系边界

- **topics/**：知识论证（是什么/为什么）——Testing 是验证（对不对）；
- **AI_Skills/**：技能资产——Testing 的 TC-SKL 负责其回放验证；
- **topics/knowledge-graph/**：机读概念图谱——kg-check 入 E0 第 8 步，与 06-契约语义测试的 TEST-C2 语义矩阵互链。

---

**最后更新**: 2026-11-18
