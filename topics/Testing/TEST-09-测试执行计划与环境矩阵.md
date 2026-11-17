# T.09 测试执行计划与环境矩阵

> **本文档定位**：定义本地执行者 hermes 的测试环境分级、执行频率、任务包格式与结果归档规则。不替代 TEST-02/03/04 的用例内容，而是给出"什么环境跑什么用例、如何被 hermes 解析执行"的操作约定。

## 目录

- [T.09 测试执行计划与环境矩阵](#t09-测试执行计划与环境矩阵)
  - [目录](#目录)
  - [T.09.1 执行环境矩阵](#t091-执行环境矩阵)
  - [T.09.2 执行频率计划](#t092-执行频率计划)
  - [T.09.3 hermes 任务包格式](#t093-hermes-任务包格式)
  - [T.09.4 环境前置检查](#t094-环境前置检查)
  - [T.09.5 结果收集与归档](#t095-结果收集与归档)
  - [T.09.6 与现有文档的衔接](#t096-与现有文档的衔接)
  - [T.09.7 参考来源](#t097-参考来源)

---

## T.09.1 执行环境矩阵

四级环境从静态检查到 K8s 集群逐级加重；hermes 按环境可用性自动选择可执行域，缺失时标记 SKIP。

| 环境 | 前置条件（工具版本核实命令） | 可执行用例域 | 预计耗时 |
| ------ | ------------------------------ | -------------- | ---------- |
| E0 本地 Git Bash | `bash --version` ≥ 4.4；`find`/`awk` 可用；项目仓库已 clone | doc-self-check quick/full、bash -n 语法检查、TSV 注册表校验、TC-DEP-05/06/08/08c/08d、TC-INT-12 静态层 | 2-5 min |
| E1 Podman | `podman --version` ≥ 4.0；`podman compose version` 可用；磁盘余量 >10G | TC-DEP-01~04（compose-kafka/nats/rabbitmq/all 的 podman 变体）、mq-smoke-test.sh 每系统 | 15-25 min |
| E2 Docker | `docker --version` ≥ 20.10；`docker compose version` 可用；磁盘余量 >20G | E1 全部用例的 docker 变体 + compose-all 集成 + TC-DEP-04c/04d/10/11b/11c + TC-INT-09~12 | 30-60 min |
| E3 K8s | `kubectl version` 可连集群；kind/k3s/minikube 单节点 ready；Helm/KEDA 可选 | TC-CLU-01~08/06b/06c/07b/07c、TC-OBS-04/08、prometheus 规则加载、keda-scaledobject-kafka.yaml 应用 | 45-90 min |

环境选择原则【论证】：静态检查不依赖容器，必须每次提交全量跑；容器化用例按组织内实际运维工具选择 Podman 或 Docker，同一用例不得同时在两种容器运行时重复计入通过；K8s 用例保留"发布前关键集"而非全量，避免本地集群资源耗尽。

矩阵的降级口径：E1/E2 互斥——hermes 探测到哪种容器运行时可用即执行对应变体，另一列记 N/A；E3 缺失时整体 SKIP 并附原因，不转为 FAIL。

## T.09.2 执行频率计划

| 触发时机 | 环境 | 用例范围 | 通过门禁 |
| ---------- | ------ | ---------- | ---------- |
| 每次提交 | E0 全量 | doc-self-check quick、bash -n、TSV 校验、TC-DEP-05/06/08/08c/08d | ERROR=0，WARN 挂账登记 |
| 夜间 | E1 或 E2 冒烟 | mq-smoke-test.sh + TC-DEP-01 每系统（kafka/nats/rabbitmq） | FAIL=0，SKIP 有原因 |
| 每周 | E2 全量集成 | TC-DEP-01~04/04c/04d、TC-INT-09~12、TC-DEP-10/11b/11c | 部署+集成用例 PASS 率 ≥ 95% |
| 发布前 | E3 集群关键集 | TC-CLU-01/02/03/06b/06c、TC-OBS-04/08、prometheus 规则加载 | 关键集 0 FAIL |

频率背后的成本约束【论证】：E2 全量集成每周一次已能覆盖常见回归；E3 集群测试每次发布前执行关键集即可满足"发布不阻断"，完整混沌集保留月度 L5 执行（TEST-01 T.01.2）。

## T.09.3 hermes 任务包格式

每个执行周期生成一个 YAML 任务包，hermes 解析后按环境→用例列表→产物路径执行。

```yaml
# hermes-task-package-example.yaml
plan:
  id: nightly-2026-11-18
  trigger: nightly
  runner: hermes
environments:
  - name: E0
    engine: local-git-bash
    precheck: ./topics/scripts/doc-self-check.sh quick
    cases:
      - id: TC-DEP-05
        script: ./topics/scripts/validate-config.sh
        args: [topics/config-templates/kafka-server.properties.template]
      - id: TC-DEP-08
        script: ./topics/scripts/validate-config.sh
        args: [topics/config-templates/nats-server.conf]
  - name: E2
    engine: docker
    precheck: docker compose version
    cases:
      - id: TC-DEP-01
        script: ./topics/scripts/mq-smoke-test.sh
        args: [kafka]
        artifacts: [results/YYYY-MM-DD/E2-TC-DEP-01.json]
artifacts:
  base_dir: results/YYYY-MM-DD
  formats: [json, log]
```

任务包校验清单（hermes 解析前强制检查）：

- 每个 `environment.engine` 必须是 `local-git-bash` / `podman` / `docker` / `k8s` 之一；
- 每个 `case.id` 必须在项目用例库中存在；
- `artifacts` 路径必须以 `results/<plan-id>/` 开头；
- 同一任务包内不得出现重复 `case_id`。

任务包由 TEST-09 附录"周期-环境-用例对照表"生成；新增用例必须在该附录登记，否则 hermes 不自动纳入任何执行周期。附录格式：

```text
周期: nightly
  E0: TC-DEP-05, TC-DEP-06, TC-DEP-08, TC-DEP-08c, TC-DEP-08d
  E1/E2: mq-smoke-test.sh kafka, mq-smoke-test.sh nats, mq-smoke-test.sh rabbitmq
周期: weekly
  E2: TC-DEP-01~04, TC-DEP-04c, TC-DEP-04d, TC-DEP-10, TC-DEP-11b, TC-DEP-11c, TC-INT-09~12
周期: pre-release
  E3: TC-CLU-01, TC-CLU-02, TC-CLU-03, TC-CLU-06b, TC-CLU-06c, TC-OBS-04, TC-OBS-08
```

## T.09.4 环境前置检查

hermes 在执行用例前运行环境预检脚本，缺失时优雅降级。

```bash
#!/bin/bash
# hermes-env-precheck.sh
check_e0() {
  bash --version | head -1
  command -v awk >/dev/null && command -v find >/dev/null
}
check_e1() {
  command -v podman >/dev/null && podman compose version >/dev/null 2>&1
}
check_e2() {
  command -v docker >/dev/null && docker compose version >/dev/null 2>&1
}
check_e3() {
  command -v kubectl >/dev/null && kubectl cluster-info >/dev/null 2>&1
}

# 调用示例
check_e0 || { echo "E0_UNAVAILABLE"; exit 3; }
check_e2 || { echo "SKIP: E2 docker unavailable"; exit 2; }
```

降级决策表：

| 预检结果 | hermes 处置 | 状态标记 |
| ---------- | ------------- | ---------- |
| E0 失败 | 整体 BLOCK，停止后续环境 | BLOCK |
| E1 可用、E2 不可用 | 执行 E1 变体，E2 列记 N/A | SKIP/E1 |
| E1/E2 均不可用 | 容器化用例全部 SKIP | SKIP |
| E3 不可用 | 集群用例 SKIP，继续 E0/E1/E2 | SKIP |
| 用例 precheck 失败 | 该用例 SKIP，同环境其余用例继续 | SKIP |

降级规则：

- E0 不可用 → 整体 BLOCK，因静态检查是所有周期的基线。
- E1/E2 同时不可用 → 容器化用例全部 SKIP。
- E1 可用但 E2 不可用 → 执行 E1 变体，E2 列记 N/A。
- E3 不可用 → 集群用例 SKIP，不阻断 E0/E1/E2 执行。

## T.09.5 结果收集与归档

results/ 目录结构：

```text
results/
├── 2026-11-18/
│   ├── E0-doc-check.json
│   ├── E2-TC-DEP-01.json
│   ├── E2-TC-DEP-01.log
│   ├── E3-TC-CLU-01.json
│   └── summary.md
```

每个用例产物必须包含：

```json
{
  "case_id": "TC-DEP-01",
  "env": "E2",
  "result": "PASS",
  "duration_seconds": 45,
  "exit_code": 0,
  "log_path": "results/2026-11-18/E2-TC-DEP-01.log",
  "artifacts": []
}
```

产物校验规则：

- JSON 产物必须含 `case_id`/`env`/`result`/`duration_seconds`/`exit_code` 五字段；
- log 文件最后三行必须能被正则 `^RESULT: (PASS|FAIL|SKIP)$`、`^DURATION: [0-9]+$`、`^EXIT_CODE: [0-3]$` 解析；
- `summary.md` 必须含执行率、通过率、缺口率三行；
- 校验失败产物移入 `results/<date>/invalid/` 并告警。

保留策略：

- E0 每次提交产物保留 30 天；
- E1/E2 夜间/周产物保留 90 天；
- E3 发布前产物保留至下次发版后 180 天；
- summary.md 永久保留，作为历史趋势数据源。

## T.09.6 与现有文档的衔接

| 文档 | 衔接点 |
| ------ | -------- |
| TEST-01 | 五层金字塔与质量门禁是频率计划的来源 |
| TEST-02 | TC-DEP-xx 用例在 E1/E2 执行 |
| TEST-04 | TC-CLU-xx 用例在 E3 执行 |
| TEST-06 | doc-self-check.sh / mq-smoke-test.sh 在 E0/E1/E2 的调用约定 |
| TEST-08 | 覆盖矩阵是任务包生成的输入 |
| TEST-10 | 用例格式与脚本规范是任务包可解析的前提 |

## T.09.7 参考来源

- 项目内：[TEST-01](TEST-01-测试体系总览与分层策略.md)、[TEST-02](TEST-02-运维部署测试用例.md)、[TEST-04](TEST-04-集群测试验证.md)、[TEST-06](TEST-06-自我验证机制与脚本说明.md)、[TEST-08](TEST-08-测试覆盖矩阵.md)、[TEST-10](TEST-10-用例编写与执行规范.md)、[config-templates/](../config-templates/)
- 外部：[Podman 官方文档](https://docs.podman.io/)、[Docker Compose 规范](https://docs.docker.com/compose/)、[kind 快速开始](https://kind.sigs.k8s.io/docs/user/quick-start/)

---

**最后更新**: 2026-11-18
