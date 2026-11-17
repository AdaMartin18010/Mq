# 06-行为验证层：Microcks 集成

> 层定位：L2 spec 的**行为级**验证（mock + contract test），与 04-行为用例/ 的自研 dry-run 脚本互补（04=轻量自研门禁，06=国际标准工具）。
> 工具事实：[Microcks 2026-05 升 CNCF Incubating](https://www.cncf.io/blog/2026/05/07/microcks-becomes-a-cncf-incubating-project/)，支持 AsyncAPI mock 与 Kafka/AsyncAPI contract test。镜像与版本首次实跑时以 quay.io/microcks/microcks 官方为准。

## 集成步骤

```bash
# 1. 启动（用户在场批次）
docker compose -f Testing/fixtures/docker-compose-microcks.yml up -d
# 2. 导入场景 spec（8 个 asyncapi.yaml）——UI 上传或 API（/api/artifact）
#    首个导入对象：契约语义测试/03-业务场景/01-order-lifecycle/asyncapi.yaml
# 3. 生成 mock（Microcks 按 spec 自动建立 mock endpoint）
# 4. contract test：将 mock 对照 E1/E2 真实 broker 流量断言
```

## 断言映射（场景 invariant → Microcks 能力边界）【论证】

| contract.yaml invariant | Microcks 可表达 | 需回退自研脚本（04-行为用例） |
| ---- | ---- | ---- |
| 结构/枚举/必填（schema 层） | ✅ contract test 直接断言 | — |
| 幂等键存在性（header） | ✅（headers 断言） | — |
| 顺序性/状态机单调（跨消息时序） | ⚠️ 有限（test 脚本可部分表达） | tc-assert 扩展 |
| 背压/延迟/TTL（时间语义） | ❌ 非契约测试范畴 | TC-SEM-07 族 |
| 死信路径 | ⚠️ 需构造失败场景脚本 | TC-SEM-05 族 |

结论：Microcks 覆盖**结构契约+头部契约**层；**时序/时间语义**仍归 TC-SEM 自研用例——两层互补而非替代。

## 漂移联动

spec 变更 → contract-drift-check --format=ids → hermes-task-gen --drift → nightly 重跑 Microcks contract test（TC-CON-01/02 注册于 registry）。

---

**最后更新**: 2026-11-18
