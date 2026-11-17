# 机器可运行知识图谱（knowledge-graph/）

> **定位**: 批次 104（方向 5 收官）。01-58 概念卡（人读）→ 本图谱（机读）→ 01-78/79/80 各图（图解）的三层表征体系中的机读层。
> **格式**: JSON-LD（用户选定标准路线）——W3C 标准，schema.org/skos 词汇对齐，可被任何 JSON-LD 工具链消费（rdflib/jena）。

## 文件

| 文件 | 内容 |
| ---- | ---- |
| `context.jsonld` | @context：mq: 词表 + skos/schema.org 映射 |
| `graph.jsonld` | 种子图：概念/维度/系统/场景节点 + 关系边（specializes/mutuallyExclusiveWith/partOf/implies/supportedBy/requires/evaluatedBy） |
| `rules.json` | 判定规则（蕴含闭包/互斥冲突/能力缺失三型） |

## 用法

```bash
python3 topics/scripts/kg-query.py --check                # 图谱完整性校验（悬空引用/互斥违规）
python3 topics/scripts/kg-query.py --concept 死信队列      # 概念卡 + 关系遍历
python3 topics/scripts/kg-query.py --judge --scenario 01-order-lifecycle --system Kafka   # 场景×系统适配判定
```

判定输出三态：`SUPPORTED / MISSING:<概念> / CONFLICT:<互斥对>`——对应契约语义测试的选型前置检查。

## 维护纪律

1. 概念节点只增不改名（名即锚点）；定义修订同步 01-58；
2. 关系边须有文档出处（source 字段指向 01-58 卡号或 TEST-14 矩阵格）；
3. 系统能力边（supportedBy）的 degree ∈ {native, config, app-level, none}，与 TEST-14 矩阵 ●◐○— 一致；
4. `--check` 已入 E0 第 8 步，图破坏即门禁红。

---

**最后更新**: 2026-11-18
