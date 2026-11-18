#!/usr/bin/env python3
# kb-meta-query.py：知识元查询——跨 doc-layer-archive/doc-argument-annotation/coverage-matrix/evidence-index 联接（批次160）
# 用法:
#   kb-meta-query.py --layer L1                 # 该理论层的文档清单+论证型分布
#   kb-meta-query.py --argument 归纳             # 该论证型的文档清单（可质疑清单入口）
#   kb-meta-query.py --gap                      # L1/L2 层中 coverage=unverified 的断言（知识缺口=hermes 输入）
#   kb-meta-query.py --doc <编号>               # 单文档四视角（层/论证型/覆盖/实证）
import sys, csv, re, collections

BASE = ["topics/scripts"]

def rd(name):
    rows = []
    with open(f"topics/scripts/{name}", encoding="utf-8") as f:
        for line in f:
            if line.startswith("#") or not line.strip(): continue
            rows.append(line.rstrip("\r\n").split("\t"))
    return rows

layer = {r[0]: r[1:] for r in rd("doc-layer-archive.tsv") if r[0] != "doc_path"}
argt = {r[0]: r[1:] for r in rd("doc-argument-annotation.tsv") if r[0] != "doc_path"}
cov = [r for r in rd("coverage-matrix.tsv") if r[0] != "doc" and len(r) >= 4]
ev = [r for r in rd("evidence-index.tsv") if r[0] != "case_id" and len(r) >= 4]

def did(path):
    m = re.search(r"(\d{2}-\d{2})-", path)
    return m.group(1) if m else path[:30]

args = sys.argv[1:]
if "--layer" in args:
    q = args[args.index("--layer")+1]
    hits = [(d, v) for d, v in layer.items() if q in v[0]]
    ac = collections.Counter(argt.get(d, ["?"])[0] for d, _ in hits)
    print(f"层 {q}: {len(hits)} 篇 | 论证型分布 {dict(ac)}")
    for d, v in sorted(hits)[:12]: print(f"  {did(d)} [{v[0]}] 论证型={argt.get(d,['?'])[0]}")
elif "--argument" in args:
    q = args[args.index("--argument")+1]
    hits = [d for d, v in argt.items() if v[0] == q]
    print(f"论证型 {q}: {len(hits)} 篇（可质疑/复核清单）")
    for d in sorted(hits)[:12]: print(f"  {did(d)} 层={layer.get(d,['?'])[0]}")
elif "--gap" in args:
    gaps = [c for c in cov if c[3] == "unverified"]
    print(f"知识缺口（unverified 断言 {len(gaps)} 条）——hermes 执行输入：")
    for c in gaps: print(f"  {c[0]} §{c[1]} {c[2][:40]} | 挂账: {c[4][:50]}")
elif "--doc" in args:
    q = args[args.index("--doc")+1]
    for d, v in layer.items():
        if q in d:
            print(f"{d}\n  层={v[0]} 论证型={argt.get(d,['?'])[0]} 置信上限={argt.get(d,['?'])[2] if len(argt.get(d,[]))>2 else '?'}")
            for c in cov:
                if c[0] in d: print(f"  覆盖[{c[3]}]: {c[2][:50]}")
else:
    print("用法: --layer L1 | --argument 归纳 | --gap | --doc <编号>")
