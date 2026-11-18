#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
doc-argument-annotate.py
全量标注消息队列知识库论证资产（topics/ + concept/，排除 README.md）的论证型。
输出：topics/scripts/doc-argument-annotation.tsv
"""

import csv
import sys
from collections import Counter
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
OUT_TSV = REPO_ROOT / "topics" / "scripts" / "doc-argument-annotation.tsv"

# 论证型集合
ARG_TYPES = {"演绎", "归纳", "类比", "溯因", "案例", "基准", "形式"}
CONF_CEILINGS = {"定理", "论证", "估算"}

# 指定路径的精确覆盖（优先级最高）
MISUSE_OVERRIDES = {
    "topics/01-基础概念与对比分析/01-04-形式化证明框架.md": {
        "primary": "形式",
        "secondary": "演绎",
        "ceiling": "论证",
        "note": "MISUSE：∀/∃符号未机器验证，形式段置信上限应降为【论证】",
    },
    "topics/02-场景驱动架构设计/02-09-性能优化案例.md": {
        "primary": "案例",
        "secondary": "类比",
        "ceiling": "论证",
        "note": "MISUSE：单一生产案例过度推广为通用优化路径",
    },
    "topics/01-基础概念与对比分析/01-08-权威数据与基准测试.md": {
        "primary": "基准",
        "secondary": "归纳",
        "ceiling": "论证",
        "note": "MISUSE：峰值数据未附负载/硬件/版本条件，易被误读为业务保底",
    },
}

# 精确路径规则（次优先级）
EXACT_OVERRIDES = {
    "topics/01-基础概念与对比分析/01-63-Exactly-once语义全论证.md": {
        "primary": "演绎",
        "secondary": "形式",
        "ceiling": "定理",
        "note": "协议语义演绎，规范原文推导，定理上限",
    },
    "topics/01-基础概念与对比分析/01-64-MQTT-5.0协议全解析.md": {
        "primary": "演绎",
        "secondary": "形式",
        "ceiling": "定理",
        "note": "协议语义演绎，规范原文推导，定理上限",
    },
    "topics/01-基础概念与对比分析/01-71-Kafka线上协议深度解析.md": {
        "primary": "演绎",
        "secondary": "形式",
        "ceiling": "定理",
        "note": "协议语义演绎，规范原文推导，定理上限",
    },
    "topics/01-基础概念与对比分析/01-86-AsyncAPI构件语义全书.md": {
        "primary": "演绎",
        "secondary": "形式",
        "ceiling": "定理",
        "note": "协议语义演绎，规范原文推导，定理上限",
    },
    "topics/01-基础概念与对比分析/01-60-前沿瞭望：2026-11技术扫描.md": {
        "primary": "归纳",
        "secondary": "溯因",
        "ceiling": "论证",
        "note": "多版本/多案例趋势归纳，演化解释溯因",
    },
    "topics/04-动态系统论与演化分析/04-06-消息系统技术演化动力学.md": {
        "primary": "归纳",
        "secondary": "溯因",
        "ceiling": "论证",
        "note": "多版本/多案例趋势归纳，演化解释溯因",
    },
    "topics/04-动态系统论与演化分析/04-09-技术采纳周期量化.md": {
        "primary": "归纳",
        "secondary": "溯因",
        "ceiling": "论证",
        "note": "多版本/多案例趋势归纳，演化解释溯因",
    },
    "topics/01-基础概念与对比分析/01-72-消息与数据编码对比矩阵.md": {
        "primary": "基准",
        "secondary": "归纳",
        "ceiling": "论证",
        "note": "可复现测量基准，多方案趋势归纳",
    },
    "topics/01-基础概念与对比分析/01-85-数据描述语言谱系.md": {
        "primary": "基准",
        "secondary": "归纳",
        "ceiling": "论证",
        "note": "可复现测量基准，多方案趋势归纳",
    },
    "topics/03-架构与运维实践/03-66-性能基准实测指南.md": {
        "primary": "基准",
        "secondary": "归纳",
        "ceiling": "论证",
        "note": "可复现测量基准，多方案趋势归纳",
    },
    "topics/02-场景驱动架构设计/02-04-场景化形式化证明.md": {
        "primary": "形式",
        "secondary": "演绎",
        "ceiling": "论证",
        "note": "场景形式化规约，证明草图未机器验证",
    },
    "topics/examples/01-编程语言对比分析.md": {
        "primary": "类比",
        "secondary": "基准",
        "ceiling": "论证",
        "note": "多语言客户端能力类比，编码效率基准",
    },
}

# 前缀/范围规则
INDUCTIVE_ABDUCTIVE_PREFIXES = [
    "01-53-", "01-54-", "01-55-", "01-56-", "01-57-",
]


def stem_has_any(basename: str, prefixes):
    return any(basename.startswith(p) for p in prefixes)


def annotate(doc_path: str, basename: str) -> dict:
    """根据路径和文件名生成单篇文档的论证型标注。"""
    # 最高优先级：误用覆盖
    if doc_path in MISUSE_OVERRIDES:
        return dict(MISUSE_OVERRIDES[doc_path])

    # 次优先级：精确覆盖
    if doc_path in EXACT_OVERRIDES:
        return dict(EXACT_OVERRIDES[doc_path])

    # 关键词启发（不覆盖已由误用/精确规则处理的文档）
    if any(k in basename for k in ("基准", "性能测试", "性能基准", "权威数据", "编码对比")):
        return {
            "primary": "基准",
            "secondary": "归纳",
            "ceiling": "论证",
            "note": "可复现测量基准，多方案趋势归纳",
        }
    if "形式化" in basename:
        return {
            "primary": "形式",
            "secondary": "演绎",
            "ceiling": "论证",
            "note": "形式化规约或证明草图，未机器验证",
        }
    if any(k in basename for k in ("协议", "语义全书", "MQTT", "Exactly-once")):
        return {
            "primary": "演绎",
            "secondary": "形式",
            "ceiling": "论证",
            "note": "协议语义演绎，规范原文推导",
        }
    if any(k in basename for k in ("演化", "动力学", "反脆弱", "博弈", "控制回路")):
        return {
            "primary": "溯因",
            "secondary": "形式",
            "ceiling": "论证",
            "note": "现象最佳解释溯因，动力学模型辅助",
        }
    if any(k in basename for k in ("案例", "实例")):
        return {
            "primary": "案例",
            "secondary": "类比",
            "ceiling": "论证",
            "note": "生产实例案例，系统间迁移类比",
        }
    if any(k in basename for k in ("迁移", "映射", "选型决策", "对比矩阵")):
        return {
            "primary": "类比",
            "secondary": "案例",
            "ceiling": "论证",
            "note": "系统间/概念映射类比，生产案例支撑",
        }

    # 01-63/64/71/86 已由 EXACT_OVERRIDES 处理；这里兜底同系列协议语义文档
    if any(basename.startswith(p) for p in ("01-63-", "01-64-", "01-71-", "01-86-")):
        return {
            "primary": "演绎",
            "secondary": "形式",
            "ceiling": "定理",
            "note": "协议语义演绎，规范原文推导，定理上限",
        }

    # 归纳+溯因范围
    if (
        basename.startswith("01-60-")
        or stem_has_any(basename, INDUCTIVE_ABDUCTIVE_PREFIXES)
        or basename.startswith("04-06-")
        or basename.startswith("04-09-")
    ):
        return {
            "primary": "归纳",
            "secondary": "溯因",
            "ceiling": "论证",
            "note": "多版本/多案例趋势归纳，演化解释溯因",
        }

    # 基准+归纳范围
    if basename.startswith(("01-72-", "01-85-", "03-66-")):
        return {
            "primary": "基准",
            "secondary": "归纳",
            "ceiling": "论证",
            "note": "可复现测量基准，多方案趋势归纳",
        }

    # 02 系列：设计/案例 + 类比
    if doc_path.startswith("topics/02-场景驱动架构设计/"):
        return {
            "primary": "案例",
            "secondary": "类比",
            "ceiling": "论证",
            "note": "生产/设计场景案例，系统间迁移类比",
        }

    # 03 系列：案例 + 归纳
    if doc_path.startswith("topics/03-架构与运维实践/"):
        return {
            "primary": "案例",
            "secondary": "归纳",
            "ceiling": "论证",
            "note": "落地实例案例，运维经验归纳",
        }

    # 04 系列其余：溯因 + 模型
    if doc_path.startswith("topics/04-动态系统论与演化分析/"):
        return {
            "primary": "溯因",
            "secondary": "形式",
            "ceiling": "论证",
            "note": "现象最佳解释溯因，动力学模型辅助",
        }

    # KB 治理族：演绎（治理公理）
    if basename.startswith("KB_"):
        return {
            "primary": "演绎",
            "secondary": "",
            "ceiling": "论证",
            "note": "治理公理演绎，项目约定非数学定理",
        }

    # concept/ 人话导读层：归纳 + 溯因/演绎
    if doc_path.startswith("concept/"):
        if basename in ("00-论证标准导论.md", "05-论证方法分类学.md"):
            return {
                "primary": "归纳",
                "secondary": "演绎",
                "ceiling": "论证",
                "note": "论证标准归纳，治理规则演绎引用",
            }
        if basename in ("02-六系统论证链.md", "03-场景论证链.md"):
            return {
                "primary": "类比",
                "secondary": "案例",
                "ceiling": "论证",
                "note": "六系统/场景间类比，生产案例支撑",
            }
        return {
            "primary": "归纳",
            "secondary": "溯因",
            "ceiling": "论证",
            "note": "人类阅读层知识归纳，动态系统溯因辅助",
        }

    # topics 根目录元文档：知识综合与治理引用
    if doc_path.startswith("topics/") and doc_path.count("/") == 1:
        return {
            "primary": "归纳",
            "secondary": "演绎",
            "ceiling": "论证",
            "note": "知识综合归纳，治理规则演绎引用",
        }

    # 兜底
    return {
        "primary": "归纳",
        "secondary": "演绎",
        "ceiling": "论证",
        "note": "知识综合归纳，规范演绎辅助",
    }


def discover_docs():
    docs = []
    for top in ("topics", "concept"):
        for p in sorted((REPO_ROOT / top).rglob("*.md")):
            if p.name == "README.md":
                continue
            rel = p.relative_to(REPO_ROOT).as_posix()
            docs.append(rel)
    return docs


def main():
    docs = discover_docs()
    rows = []
    for doc_path in docs:
        basename = Path(doc_path).name
        ann = annotate(doc_path, basename)
        rows.append({
            "doc_path": doc_path,
            "primary_type": ann["primary"],
            "secondary_type": ann["secondary"],
            "confidence_ceiling": ann["ceiling"],
            "note": ann["note"],
        })

    # 校验
    assert len(rows) > 0, "未发现待标注文档"
    for r in rows:
        assert r["primary_type"] in ARG_TYPES, r
        assert r["secondary_type"] == "" or r["secondary_type"] in ARG_TYPES, r
        assert r["confidence_ceiling"] in CONF_CEILINGS, r

    # 写出 TSV
    with open(OUT_TSV, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["doc_path", "primary_type", "secondary_type", "confidence_ceiling", "note"],
            delimiter="\t",
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)

    # 统计
    primary_counts = Counter(r["primary_type"] for r in rows)
    ceiling_counts = Counter(r["confidence_ceiling"] for r in rows)
    misuse_count = sum(1 for r in rows if r["note"].startswith("MISUSE"))

    print(f"已生成：{OUT_TSV.relative_to(REPO_ROOT)}")
    print(f"扫描到文档：{len(rows)} 篇，已全量标注（覆盖率 100%）")
    print("\n主论证型分布：")
    for t in sorted(ARG_TYPES):
        print(f"  {t}: {primary_counts.get(t, 0)}")
    print("\n置信上限分布：")
    for c in sorted(CONF_CEILINGS):
        print(f"  {c}: {ceiling_counts.get(c, 0)}")
    print(f"\n误用标记数：{misuse_count}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
