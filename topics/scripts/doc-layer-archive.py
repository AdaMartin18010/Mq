#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
doc-layer-archive.py — 全库文档五层理论塔归档生成器

目标：为 topics/ 全部 Markdown 文档（以及 KB 族、Testing 规范）生成
      doc_path | layer | sub_layer | basis 四列 TSV，覆盖率 100%。

设计原则：
1. 幂等可重跑：相同仓库状态永远输出相同 TSV。
2. 规则初标 + 显式覆写：通用规则处理批量文件，OVERRIDES 承载跨层/特例的人工复核结论。
3. 不可漏行：任何匹配到的文件若未被规则/覆写命中，脚本报错退出，强制 100% 覆盖。
4. 中文 basis：一句归档依据，便于 concept/04-理论层次架构.md 引用。

五层定义（与 concept/04-理论层次架构.md 对齐）：
  L0 公理层   — 不可再分的前提、治理公理、术语/选型根基
  L1 语义定律层 — 由公理+协议规范推导的定律、形式化框架、协议全解析
  L2 模型层   — 排队论/系统动力学/博弈/控制回路/S曲线等可计算模型
  L3 模式层   — 工程模式、设计原理、架构/选型论证
  L4 实例层   — 落地操作、检查清单、场景包、测试用例、案例
"""

from pathlib import Path
import sys
import re

REPO_ROOT = Path(__file__).resolve().parents[2]  # E:/_src/Mq
TOPICS_DIR = REPO_ROOT / "topics"
TESTING_DIR = REPO_ROOT / "Testing"
OUT_PATH = TOPICS_DIR / "scripts" / "doc-layer-archive.tsv"

# ---------------------------------------------------------------------------
# 显式覆写表：逐域人工复核结论（规则初标后的纠偏与跨层标注）
# key = 相对仓库根目录的 POSIX 路径
# value = (layer, sub_layer, basis)
# ---------------------------------------------------------------------------
OVERRIDES = {
    # ---- L0/L1 跨层：既是公理/概念根基，又承载语义定律 ----
    "topics/01-基础概念与对比分析/01-58-全局核心概念卡片总表.md": (
        "L0/L1", "概念公理+语义定律",
        "108 概念六元组是 L0 命名公理，又直接支撑 L1 语义定律的推理基线"
    ),
    "topics/01-基础概念与对比分析/01-59-全局选型决策总树.md": (
        "L0/L1", "约束公理+选型定律",
        "将业务约束公理映射为可执行的选型判定树，跨公理层与定律层"
    ),
    "topics/01-基础概念与对比分析/01-23-术语词汇表.md": (
        "L0/L1", "术语公理",
        "统一术语定义是 L0 公理的语言化身，亦是 L1 定律的推理前提"
    ),

    # ---- L1 语义定律层：协议/形式化/语义旗舰 ----
    "topics/01-基础概念与对比分析/01-04-形式化证明框架.md": (
        "L1", "形式化定律",
        "给出语义定律的形式化骨架与 P3 置信标注框架"
    ),
    "topics/01-基础概念与对比分析/01-63-Exactly-once语义全论证.md": (
        "L1", "交付语义定律",
        "由 Two Generals/FLP 公理推导 exactly-once 边界，并映射六系统协议实现"
    ),
    "topics/01-基础概念与对比分析/01-64-MQTT-5.0协议全解析.md": (
        "L1", "协议语义定律",
        "MQTT 5.0 QoS 语义、会话/遗嘱/保留等协议定律的系统级论证"
    ),
    "topics/01-基础概念与对比分析/01-71-Kafka线上协议深度解析.md": (
        "L1", "协议语义定律",
        "Kafka 请求/响应协议与幂等/事务语义的线上定律解析"
    ),

    # ---- L1/L2 跨层：DSL/语言基础同时是模型与定律 ----
    "topics/01-基础概念与对比分析/01-82-系统语言框架与AsyncAPI六维映射矩阵.md": (
        "L1/L2", "语言模型+语义定律",
        "系统语言框架与六维映射同时承担语义定律（映射规则）与模型（结构关系）角色"
    ),
    "topics/01-基础概念与对比分析/01-83-DSL通论：语言设计基础.md": (
        "L1/L2", "语言模型",
        "DSL 元模型是 L2 可计算结构，亦是 L1 契约语义的表达基础"
    ),
    "topics/01-基础概念与对比分析/01-84-消息DSL通用模式全集.md": (
        "L1/L3", "模式元模型+语义定律",
        "12 大通用模式是 L3 模式的元模型，同时定义 L1 语义契约的最小表达"
    ),
    "topics/01-基础概念与对比分析/01-85-数据描述语言谱系.md": (
        "L1/L2", "语言模型",
        "数据描述语言谱系提供 L2 语言演化模型，并支撑 L1 Schema 定律"
    ),
    "topics/01-基础概念与对比分析/01-86-AsyncAPI构件语义全书.md": (
        "L1", "规范语义定律",
        "AsyncAPI 构件语义是 L1 层规范定律的完整展开"
    ),

    # ---- L0 治理公理：KB 族与项目元文档 ----
    "topics/KB_CHARTER.md": ("L0", "治理公理", "AI 知识权威宪章，定义 P3 置信消费的治理公理"),
    "topics/KB_DIVISION.md": ("L0", "治理公理", "主控/hermes 分工公理，确定知识生产与执行的权威边界"),
    "topics/KB_ENDORSEMENT.md": ("L0", "治理公理", "知识背书等级与证据要求的治理公理"),
    "topics/KB_GOVERNANCE.md": ("L0", "治理公理", "全库治理流程与修订程序的治理公理"),
    "topics/KB_REF_AUDIT.md": ("L0", "治理公理", "引用审计与二手来源纠正的治理公理"),
    "topics/PROJECT_STATUS.md": ("L0", "状态公理", "项目唯一权威状态，所有完成度声明的校准公理"),
    "topics/ROADMAP.md": ("L0", "路线公理", "版本追踪与批次规划的治理公理"),
    "topics/CHANGELOG.md": ("L0", "演化公理", "知识版本变更的时序公理"),
    "topics/CONTRIBUTING.md": ("L0", "协作公理", "贡献者与 Agent 协作的治理公理"),
    "topics/INDEX.md": ("L0/L4", "导航实例+治理公理", "全量导航同时是治理索引（L0）与阅读实例（L4）"),
    "topics/README.md": ("L0/L4", "门面公理+导航实例", "项目门面定义知识库定位公理，亦是 L4 入口"),
    "topics/README_FIRST.md": ("L0/L4", "门面公理+导航实例", "新人第一入口，兼具定位公理与导航实例"),
    "topics/GLOSSARY.md": ("L0", "术语公理", "术语词汇统一规范，L0 语言公理"),
    "topics/CROSS_REFERENCES.md": ("L0", "关系公理", "文档间交叉引用关系，防止双源漂移的治理公理"),

    # ---- L4 实例层：导航、案例、学习路径 ----
    "topics/01-基础概念与对比分析/01-24-学习路径指南.md": (
        "L4", "学习实例", "按角色与时间给出阅读实例路径"
    ),
    "topics/01-基础概念与对比分析/01-19-选型决策矩阵.md": (
        "L3/L4", "模式+实例", "选型矩阵是 L3 设计模式，亦是可直接勾选的 L4 实例"
    ),
    "topics/01-基础概念与对比分析/01-20-技术选型速查表.md": ("L4", "速查实例", "技术选型速查表属于 L4 可执行参考卡"),
    "topics/01-基础概念与对比分析/01-21-快速参考卡片.md": ("L4", "速查实例", "快速参考卡片是 L4 口袋型实例"),
    "topics/01-基础概念与对比分析/01-22-常见问题FAQ.md": ("L4", "问答实例", "FAQ 是 L4 典型问题实例集"),

    # ---- L2 模型层：04 动态系统论 ----
    "topics/04-动态系统论与演化分析/README.md": (
        "L2/L4", "模型导航+实例", "04 系列目录导航兼具 L2 模型总览与 L4 阅读实例"
    ),
    "topics/04-动态系统论与演化分析/04-05-动态系统总结与选型决策.md": (
        "L2/L3", "模型+模式", "系统动力学总结既是 L2 模型输出，又直接支撑 L3 选型模式"
    ),

    # ---- L3 模式层：02 系列设计原理 ----
    "topics/02-场景驱动架构设计/README.md": (
        "L3/L4", "模式导航+实例", "02 系列目录导航兼具 L3 模式总览与 L4 阅读实例"
    ),

    # ---- L3/L4 跨层：03 系列早期框架性文档偏设计，后期偏操作 ----
    "topics/03-架构与运维实践/03-01-部署架构模式矩阵.md": (
        "L3", "架构模式", "部署架构模式矩阵属于 L3 架构设计论证"
    ),
    "topics/03-架构与运维实践/03-02-成本模型与监控告警.md": (
        "L3/L4", "模型+实例", "成本模型属 L2/L3，监控告警属 L4"
    ),
    "topics/03-架构与运维实践/03-03-故障场景与恢复策略.md": (
        "L3/L4", "模式+实例", "故障场景分析属 L3 模式，恢复策略属 L4 操作"
    ),
    "topics/03-架构与运维实践/03-04-场景化架构与运维决策框架.md": (
        "L3", "决策模式", "场景化决策框架是 L3 架构/运维模式"
    ),
    "topics/03-架构与运维实践/03-05-异常监控与自动恢复.md": (
        "L3/L4", "模式+实例", "自动恢复设计属 L3，监控配置属 L4"
    ),
    "topics/03-架构与运维实践/03-06-可观测性体系设计.md": (
        "L3", "设计模式", "可观测性体系设计属 L3 模式层"
    ),
    "topics/03-架构与运维实践/03-07-动态运维与自动化.md": (
        "L3/L4", "模式+实例", "动态运维模式 L3，自动化脚本 L4"
    ),
    "topics/03-架构与运维实践/03-08-SRE实践与错误预算.md": (
        "L3/L4", "模式+实例", "SRE 实践框架 L3，错误预算操作 L4"
    ),
    "topics/03-架构与运维实践/03-09-集群管理与分布式架构.md": (
        "L3", "架构模式", "集群管理与分布式架构属 L3 设计模式"
    ),
    "topics/03-架构与运维实践/03-10-Kubernetes部署实践.md": (
        "L3/L4", "模式+实例", "K8s 部署模式 L3，具体 YAML 实践 L4"
    ),
    "topics/03-架构与运维实践/03-11-故障排查手册.md": ("L4", "操作实例", "故障排查手册是 L4 可执行清单"),
    "topics/03-架构与运维实践/03-12-云服务消息队列对比.md": (
        "L3/L4", "选型模式+实例", "云服务对比属 L3 选型论证，亦是 L4 选型实例"
    ),
    "topics/03-架构与运维实践/03-13-性能调优实战案例.md": ("L4", "案例实例", "性能调优实战案例属 L4"),
    "topics/03-架构与运维实践/03-14-监控配置示例.md": ("L4", "配置实例", "监控配置示例是 L4 配置实例"),
    "topics/03-架构与运维实践/03-28-故障排查手册.md": ("L4", "操作实例", "故障排查手册（重复编号）是 L4 可执行清单"),
    "topics/03-架构与运维实践/03-35-文档管理指南.md": (
        "L0/L4", "治理公理+实例", "文档管理规范属 L0 治理，亦是 L4 操作指南"
    ),
    "topics/03-架构与运维实践/03-36-知识库管理指南.md": (
        "L0/L4", "治理公理+实例", "知识库管理规范属 L0 治理，亦是 L4 操作指南"
    ),
    "topics/03-架构与运维实践/03-37-持续集成部署指南.md": (
        "L4", "CI/CD 实例", "持续集成部署指南属 L4 工程实例"
    ),
    "topics/03-架构与运维实践/03-66-性能基准实测指南.md": (
        "L4", "实测实例", "性能基准实测指南是 L4 可复现实验实例"
    ),
    "topics/03-架构与运维实践/03-67-六系统运维画像矩阵.md": (
        "L3/L4", "模式+实例", "运维画像矩阵是 L3 模式对照，亦是 L4 检查实例"
    ),
    "topics/03-架构与运维实践/03-68-系统运行行为档案.md": (
        "L4", "行为实例", "系统运行行为档案是 L4 实测/观察实例"
    ),

    # ---- L4 实例层：模板、示例、历史归档、图谱 ----
    "topics/config-templates/README.md": ("L4", "配置实例", "生产配置模板目录的 L4 导航"),
    "topics/examples/README.md": ("L4", "代码实例", "多语言代码示例目录的 L4 导航"),
    "topics/examples/01-编程语言对比分析.md": ("L4", "代码实例", "多语言编程对比的 L4 实例"),
    "topics/archive/README.md": ("L4", "归档实例", "历史归档导航，属 L4 实例层"),
    "topics/knowledge-graph/README.md": ("L2/L4", "图谱模型+实例", "知识图谱是 L2 机读模型，亦是 L4 查询实例"),
    "topics/BEST_PRACTICES.md": ("L3/L4", "最佳实践模式+实例", "最佳实践总结跨 L3 模式与 L4 实例"),
    "topics/PRACTICE_GUIDE.md": ("L4", "实践实例", "实践指南是 L4 操作实例"),
    "topics/QUICK_START.md": ("L4", "入门实例", "快速开始是 L4 入门实例"),
    "topics/QUICK_START_GUIDE.md": ("L4", "入门实例", "快速开始指南是 L4 入门实例"),
    "topics/QUICK_REFERENCE.md": ("L4", "速查实例", "快速参考是 L4 速查实例"),
    "topics/QUICK_COMMANDS.md": ("L4", "命令实例", "快速命令是 L4 命令实例"),
    "topics/LEARNING_PATH.md": ("L4", "学习实例", "学习路径是 L4 阅读实例"),
    "topics/TEMPLATES.md": ("L4", "模板实例", "模板集合是 L4 可复用实例"),
    "topics/IMPLEMENTATION_CHECKLIST.md": ("L4", "检查实例", "实现检查单是 L4 可勾选实例"),
    "topics/SUMMARY.md": ("L0/L4", "总结公理+实例", "内容总结既是知识基线，亦是 L4 入口"),
    "topics/COMPREHENSIVE_REVIEW_AND_RECOMMENDATIONS.md": (
        "L3/L4", "审查模式+实例", "审查报告跨 L3 模式建议与 L4 实例清单"
    ),
    "topics/MCP_EXPORT_ASSESSMENT.md": ("L0/L4", "评估公理+实例", "MCP 导出评估兼具 L0 治理与 L4 评估实例"),
    "topics/DSL_ASYNCAPI_AUDIT.md": ("L1/L4", "审计定律+实例", "DSL/AsyncAPI 审计兼具 L1 规范定律与 L4 审计实例"),

    # ---- L4 实例层：Testing 规范文档 ----
    "Testing/README.md": ("L4", "测试实例", "测试体系总览是 L4 验证实例导航"),
}

# ---------------------------------------------------------------------------
# 规则引擎：按顺序匹配，第一条命中的规则生效
# 每条规则: (glob_pattern, layer, sub_layer, basis)
# ---------------------------------------------------------------------------
RULES = [
    # KB 族治理公理
    ("topics/KB_*.md", "L0", "治理公理", "KB 族定义知识权威、背书、治理与分工公理"),

    # 04 动态系统论 → L2 模型层（除 README 由 OVERRIDES 处理）
    ("topics/04-动态系统论与演化分析/04-*.md", "L2", "系统动力学模型",
     "因果回路、故障传播、演化博弈、控制回路等可计算/半形式模型"),

    # 01 系列：协议/形式化/语义旗舰 → L1
    ("topics/01-*/01-04-*.md", "L1", "形式化定律", "形式化证明框架承载语义定律的形式化骨架"),
    ("topics/01-*/01-63-*.md", "L1", "交付语义定律", "Exactly-once 语义全论证属 L1 定律层"),
    ("topics/01-*/01-64-*.md", "L1", "协议语义定律", "MQTT 5.0 协议全解析属 L1 定律层"),
    ("topics/01-*/01-71-*.md", "L1", "协议语义定律", "Kafka 线上协议深度解析属 L1 定律层"),

    # 01 系列：概念矩阵/对比/分析 → L1（概念语义层）
    ("topics/01-*/01-*.md", "L1", "概念语义", "基础概念、对比分析、系统专章属 L1 语义/概念定律层"),

    # 02 系列：设计原理与选型论证 → L3
    ("topics/02-场景驱动架构设计/02-*.md", "L3", "设计模式",
     "02 系列按 AGENTS.md 分工为设计原理与选型论证，属 L3 模式层"),

    # 03 系列：早期 03-01~03-14 偏设计框架 → L3；其余偏运维实例 → L4
    ("topics/03-架构与运维实践/03-0[1-9]-*.md", "L3", "架构/运维模式",
     "03-01~03-09 属架构与运维设计模式层"),
    ("topics/03-架构与运维实践/03-1[0-4]-*.md", "L3", "架构/运维模式",
     "03-10~03-14 属架构与运维设计模式层"),
    ("topics/03-架构与运维实践/03-*.md", "L4", "运维实例",
     "03-15 起专项指南/检查清单属 L4 落地实例层"),

    # Testing 规范文档 → L4（允许位于任意子目录）
    ("Testing/**/TEST-*.md", "L4", "测试实例", "Testing 规范文档承载可执行验证用例与场景断言"),
    ("Testing/README.md", "L4", "测试实例", "测试体系总览是 L4 验证实例导航"),

    # 子目录 README 默认 L4（导航/实例入口）
    ("topics/**/README.md", "L4", "导航实例", "子目录 README 是阅读导航与实例入口"),
    # 其他根级元文档默认 L0（治理公理）
    ("topics/*.md", "L0", "治理公理", "topics 根级元文档承载项目治理、状态、路线公理"),
]


def match_rule(rel_path: str) -> tuple:
    """对给定相对路径应用规则引擎，返回 (layer, sub_layer, basis)。"""
    for pattern, layer, sub_layer, basis in RULES:
        if rel_path_match(rel_path, pattern):
            return layer, sub_layer, basis
    return None


def rel_path_match(rel_path: str, pattern: str) -> bool:
    """
    支持 * 与 ** 通配符的路径匹配（大小写敏感）。
    pattern 中不含目录分隔符时仅匹配 basename；含分隔符时按完整相对路径匹配。
    ** 匹配任意层目录，* 匹配单段路径或文件名。
    """
    if "/" not in pattern:
        name = Path(rel_path).name
        regex = "^" + pattern.replace(".", r"\.").replace("*", ".*") + "$"
        return re.match(regex, name) is not None
    # 先把 ** 替换为占位符，避免被后面的 * 替换覆盖
    placeholder = "\x00"
    regex = pattern.replace(".", r"\.").replace("**", placeholder)
    # * 在路径段内匹配非斜杠字符；占位符匹配任意目录层级
    regex = regex.replace("*", "[^/]*").replace(placeholder, ".*?")
    regex = "^" + regex + "$"
    return re.match(regex, rel_path) is not None


def collect_files() -> list:
    """收集需要归档的文件：topics/ 全部 .md + Testing/TEST-*.md + Testing/README.md。"""
    files = []
    # topics/ 全量 Markdown
    for p in sorted(TOPICS_DIR.rglob("*.md")):
        files.append(p)
    # Testing 规范文档（不含海量单个用例，用例由场景包/SEMANTICS 在 L4 代表）
    if TESTING_DIR.exists():
        for p in sorted(TESTING_DIR.rglob("TEST-*.md")):
            files.append(p)
        readme = TESTING_DIR / "README.md"
        if readme.exists():
            files.append(readme)
    return sorted(set(files), key=lambda x: x.as_posix())


def classify(rel_path: str) -> tuple:
    """对单个文件进行分类：先查覆写，再查规则，最后报错。"""
    if rel_path in OVERRIDES:
        return OVERRIDES[rel_path]
    result = match_rule(rel_path)
    if result:
        return result
    raise ValueError(f"未分类文件（请加入 OVERRIDES 或 RULES）: {rel_path}")


def main():
    files = collect_files()
    rows = []
    stats = {}
    for p in files:
        rel = p.relative_to(REPO_ROOT).as_posix()
        layer, sub_layer, basis = classify(rel)
        rows.append((rel, layer, sub_layer, basis))
        # 统计：跨层标注按主层计数（取第一个 L 层级）
        primary = layer.split("/")[0]
        stats[primary] = stats.get(primary, 0) + 1

    # 写入 TSV
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUT_PATH.open("w", encoding="utf-8") as f:
        f.write("# doc-layer-archive.tsv\n")
        f.write("# 生成器: topics/scripts/doc-layer-archive.py（幂等可重跑）\n")
        f.write("# 列：doc_path | layer(L0-L4，主归属) | sub_layer | basis\n")
        f.write("doc_path\tlayer\tsub_layer\tbasis\n")
        for rel, layer, sub_layer, basis in rows:
            f.write(f"{rel}\t{layer}\t{sub_layer}\t{basis}\n")
        # 尾部统计
        f.write("# --- 统计 ---\n")
        total = len(rows)
        f.write(f"# TOTAL\t{total}\t-\t全库归档文档总数\n")
        for lyr in ["L0", "L1", "L2", "L3", "L4"]:
            f.write(f"# {lyr}\t{stats.get(lyr, 0)}\t-\t主归属 {lyr} 文档数\n")
        f.write(f"# COVERAGE\t100%\t-\t每篇均有归档行\n")

    # 控制台摘要
    print(f"已生成: {OUT_PATH}")
    print(f"归档总数: {total}")
    for lyr in ["L0", "L1", "L2", "L3", "L4"]:
        print(f"  {lyr}: {stats.get(lyr, 0)} 篇")
    print("覆盖率: 100%")


if __name__ == "__main__":
    main()
