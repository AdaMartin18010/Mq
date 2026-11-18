# K5 修订协调与可重建性（批次 141）

> **地位**：K1 §4 修正闭环 + 多 agent 环境的执行细则。

## 1. 知识域修订白名单（agent 权限矩阵）

| 区域 | agent 自主 | 人审（PR/审批单） | 禁改 |
| ------ | ----------- | ------------------ | ------ |
| results/、Testing/drift-inbox/、cases/ | ✅ 直接写 | — | — |
| Testing/07/08 用例骨架、evidence-index、coverage-matrix | ✅ 生成器产出 | 手工单条改须审批 | — |
| topics/ 正文、decision-registry、kg/graph | — | ✅ L3 审批单（TEST-16 模板 B） | — |
| K1/K2/K3/K4/K5 宪章族、AGENTS.md、01-04 形式化框架 | — | — | ✅ 仅用户本人（治理变更批） |

## 2. 域锁约定（多 agent 并发）

- 粒度：目录级（topics/01-…/、Testing/08/cases/<域>/）；
- 形式：`.kb-lock`（JSON：{"domain":..., "agent":..., "expires":...}），锁期 ≤2h，过期自动失效；
- 冲突：发现他人活锁 → 不得覆盖，转人工；git merge 冲突仍为最终仲裁；
- 纪律：同域禁止两 agent 并行写（本约定+E0 死链检查兜底）。

## 3. Derived 资产可重建清单（备份≠可恢复）

| 资产 | 重建方式 | 验证 |
| ------ | --------- | ------ |
| kg/graph.jsonld | 手工维护为主（155→162 节点经审计追加）；扩边脚本可重放 | `kg-query --check` 入 E0 ✓ |
| matrix-registry.tsv | 07 生成器（enrich 可重跑） | matrix-check 入 E0 ✓ |
| OPS/ERR/FAL/SYN/PST/CLU/SCL/ALT 用例 | 各生成器重跑（幂等保护） | 文件存在性+registry 双向校验 |
| evidence-index / coverage-matrix | 手工（试点期）→ 批次化生成器（挂账） | E0 挂账 |
| results/ 产物 | 不可重建=原始证据，**永不清理**（.gitignore 保留策略另审） | — |

**规则**：新增 derived 资产必须同步交付"重建脚本或重建说明"，否则不得入 E0 依赖链。

---

**最后更新**: 2026-11-18
