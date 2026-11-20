# 07-集成矩阵：维度化用例库

> **定位**（批次 117）：测试体系的**矩阵扩展层**——按"系统 × 语言 × 特性 × 转换链"四维组织集成用例，支撑后续矩阵式扩展。与 00-05 子目录（治理/职能结构）正交：那边管机制，这边管用例的维度检索与批量生成。
> 四维模型、编码规则、与 test-registry.tsv 的映射关系见本文；用例模板见 `cases/_template.md`。

## 一、四维模型

| 维 | 取值源 | 机读列 |
| ---- | ---- | ---- |
| 系统 SYS | 维度定义/systems.tsv（7 系统） | matrix-registry `sys` 列 |
| 语言 LANG | 维度定义/languages.tsv（5 语言+运行时版本） | `lang` 列 |
| 特性 FEAT | 维度定义/features.tsv（12 语义维度+4 运维特性=16，与 TEST-C2/03-67 对齐） | `feat` 列 |
| 转换链 TRX | 维度定义/transforms.tsv（4 链：DSL→AsyncAPI / AsyncAPI→代码 / binding→配置 / 契约→运行时） | `trx` 列 |

## 二、用例编码与路径规则

```text
用例 ID:  TC-<SYS>-<LANG>-<FEAT3>-<NN>     （FEAT3=特性三字母码，见 features.tsv）
文件路径: cases/<sys小写>/<lang小写>/<feat原文>/
          TC-<SYS>-<LANG>-<FEAT3>-<NN>.md
机读登记: matrix-registry.tsv 一行（case_id/sys/lang/feat/trx/status/script）
registry: 由 matrix-registry 生成 test-registry.tsv 行（119 批自动化，当前手工同步）
```

首两层走目录（系统/语言）——执行环境按系统聚合、同 broker 复用多语言客户端；特性与转换是文件内 GWT 结构 + 机读列，不做目录层（避免单根树表达不了多维的结构性问题）。

## 三、生命周期

```text
种子（117：24 条人工精修 P0 格）
 → 骨架（118：生成器产 7×5×16=560 格 dry-run 全覆盖，P0 格已含真断言）
 → 充实（逐批：ASE 断言回填 + --live 真实执行挂账集中批）
 → 流转（status: pending → mapped → verified，TEST-13 状态机）
```

## 四、与其他资产的关系

- **断言源**：Testing/06-契约语义测试/02-语义矩阵/semantics/assertions.tsv（ASE-xxx 直接引用到 GWT 的 then 行）
- **环境**：Testing/fixtures/compose（每系统片段）+ 本目录 fixtures/（每语言客户端骨架）
- **场景包映射**（120 批）：Testing/06-03-业务场景 8 包的 invariants 是矩阵用例的断言输入——对应关系：订单/支付/库存→KAFKA 格；通知→RABBITMQ 格；IoT→MQTT 格；CDC→KAFKA-ORD/IDM 格；审计→PULSAR-PST 格；任务→NATS-RET/DLQ 格。全量自动映射脚本列入挂账（场景包增删时执行）
- **转换链测试**：dsl-schema/binding-check/contract-to-odcs 的集成面在 transforms.tsv 四链定义

## 五、运行时环境声明（2026-11-20）

矩阵用例卡中的容器命令按 **podman/docker 等价替换**执行：宿主默认运行时 = Podman 6.1.4（WSL2 machine），Docker Desktop 未启动 → 用例卡内 `docker compose/exec/kill/pause/run` 一律以 `podman` 等价命令执行，**不逐卡改写**（324 条 TC-BUS 卡 + 矩阵卡共用本声明）。podman 兼容差异：`podman exec` 无 `--rm` 参数；`docker kill/pause` 语义与 podman 一致。环境与降级口径见 [TEST-09](../00-规范与计划/TEST-09-测试执行计划与环境矩阵.md) 宿主默认节。

---

**最后更新**: 2026-11-20
