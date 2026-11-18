#!/usr/bin/env python3
# 集成矩阵一致性校验（批次 119，E0 第 3 步扩展）——单进程实现
# 校验：matrix-registry 结构/枚举（对维度定义 TSV）/ID 唯一/用例文件存在/与 test-registry 同步
# 退出码：0=OK；1=存在不一致
import os, sys, csv

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASE = os.path.join(ROOT, "Testing", "07-集成矩阵")
REG = os.path.join(BASE, "matrix-registry.tsv")
TREG = os.path.join(ROOT, "topics", "scripts", "test-registry.tsv")

def rd(p):
    with open(p, encoding="utf-8") as f:
        rows = [r for r in csv.reader((l for l in f if not l.startswith("#")), delimiter="\t") if r]
    return {r[0]: r for r in rows if r and r[0] != "code"}

systems = rd(os.path.join(BASE, "维度定义", "systems.tsv"))
langs   = rd(os.path.join(BASE, "维度定义", "languages.tsv"))
feats   = rd(os.path.join(BASE, "维度定义", "features.tsv"))
treg_ids = set()
with open(TREG, encoding="utf-8") as f:
    for line in f:
        if line.startswith("#") or not line.strip():
            continue
        treg_ids.add(line.split("\t")[0].rstrip("\r\n"))

fails, total, missing = [], 0, 0
seen = set()
with open(REG, encoding="utf-8") as f:
    for line in f:
        if line.startswith("#") or not line.strip():
            continue
        cols = line.rstrip("\r\n").split("\t")
        if cols[0] == "case_id":
            continue
        total += 1
        if len(cols) != 7:
            fails.append(f"列数!=7: {cols[0]} ({len(cols)})"); continue
        cid, sys_, lang, feat, trx, status, script = cols
        if sys_ not in systems: fails.append(f"sys 非法: {cid} -> {sys_}")
        if lang not in langs: fails.append(f"lang 非法: {cid} -> {lang}")
        if feat not in feats: fails.append(f"feat 非法: {cid} -> {feat}")
        if cid in seen: fails.append(f"ID 重复: {cid}")
        seen.add(cid)
        featname = feats[feat][1] if feat in feats else None
        if featname:
            p = os.path.join(BASE, "cases", sys_.lower(), lang.lower(), featname, cid + ".md")
            if not os.path.isfile(p):
                fails.append(f"用例文件缺失: {cid}")
        if cid not in treg_ids:
            missing += 1
            fails.append(f"test-registry 缺行: {cid}")

print(f"matrix_total={total} sync_missing={missing}")
for x in fails[:20]:
    print("FAIL", x)
if len(fails) > 20:
    print(f"... 共 {len(fails)} 项")
print("MATRIX_CHECK " + ("FAIL" if fails else "OK"))
sys.exit(1 if fails else 0)
