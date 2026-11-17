# 契约治理工具链（批次 86）

> **置信口径**: 工具能力以官方文档为准；选型=【论证】。
> **时效声明**: 核实至 2026-11。
> **本文档定位**: L1-L2 层的治理工具化——契约目录、diff 漂移、规则门禁三件套，补齐"契约变更治理"环节（02-56 Spec-Driven 体系的工具落地）。

## 三件套选型与挂接

| 环节 | 工具（国际主流） | 本项目挂接 | 状态 |
| ---- | ---- | ---- | ---- |
| 契约目录 | [EventCatalog](https://www.eventcatalog.dev/)（基于 AsyncAPI 的事件目录事实标准，OSS） | 从 03-业务场景/ 8 个 asyncapi.yaml 生成目录站点；`eventcatalog.config.js` 指向本目录 | 挂账：目录生成命令加入用户在场批次（node 工具链首次安装） |
| 契约 diff | `asyncapi diff`（AsyncAPI 官方 CLI） | 场景包 spec 变更时产出 diff 报告挂 PR；与 TEST-13 §T.13.2 契约漂移链联动（diff 报告=漂移证据附件） | 挂账：同左 |
| 规则门禁 | Spectral（本项目已有 spectral-asyncapi-ruleset.yaml） | contract-spec-check.sh 已实现核心规则子集（批次71）；全量 Spectral 需 node，入真实执行批次 | 部分接入 |

## 治理流程（与 TEST-13 漂移机制合成一链）

```text
场景契约变更（contract.yaml / asyncapi.yaml）
  → ① asyncapi diff 生成破坏面报告（哪些 message/operation 变了）
  → ② contract-spec-check + contract-binding-check 静态门禁（E0，已接入）
  → ③ tc-assert-check 父用例重检（E0 第 7 步，已接入）
  → ④ Microcks contract test 重跑（TC-CON-01/02，批次78 就绪后）
  → ⑤ EventCatalog 目录重建发布（变更可见性）
  → ⑥ CHANGELOG 记条目
```

当前已自动化 ②③；①④⑤ 三挂账项统一在"用户在场批次"执行（node/docker 工具链首次安装集中处理）。

## 注册表登记

TC-AIG-01~06（域 AIG，env E0，script `-`，status pending）与 01-契约规格治理段已在 test-registry.tsv 登记（本批追加）。

---

**最后更新**: 2026-11-18
