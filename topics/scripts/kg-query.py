#!/usr/bin/env python3
# 知识图谱查询与判定引擎（knowledge-graph/，批次104）
# 用法:
#   kg-query.py --check                        完整性校验
#   kg-query.py --concept <名称>              概念卡 + 出边/入边关系遍历
#   kg-query.py --judge --scenario <名> --system <名> [--explain]   场景×系统适配判定
#   kg-query.py --path <概念A> <概念B>         最短关系路径（BFS）
#   kg-query.py --stats                        节点/边/类型统计
# 退出码: 0=OK/适配; 1=图破坏或 MISSING/CONFLICT 存在; 2=参数异常
import json, sys, os
from collections import deque, Counter

BASE = os.path.dirname(os.path.abspath(__file__))
KG = os.path.join(BASE, "..", "..", "topics", "knowledge-graph")
REL_KEYS = ["specializes", "mutuallyExclusiveWith", "partOf", "implies", "evaluatedBy"]
REQ_REL = "requires"
ALL_REL_KEYS = REL_KEYS + [REQ_REL, "supportedBy"]

def load():
    try:
        g = json.load(open(os.path.join(KG, "graph.jsonld"), encoding="utf-8"))
        r = json.load(open(os.path.join(KG, "rules.json".replace("jsonld", "json")), encoding="utf-8"))
    except Exception as e:
        print(f"FAIL 图加载: {e}"); sys.exit(1)
    return g["graph"], r["rules"]

def index(graph):
    by_name, by_id = {}, {}
    for n in graph:
        by_id[n["id"]] = n
        if "name" in n:
            by_name[n["name"]] = n
    return by_id, by_name

def closure(node, rel, by_id, seen=None):
    seen = seen if seen is not None else set()
    for tgt in node.get(rel, []) if isinstance(node.get(rel), list) else [node.get(rel)]:
        if isinstance(tgt, dict):
            tgt = tgt.get("id")
        if not tgt or tgt in seen:
            continue
        seen.add(tgt)
        if tgt in by_id:
            closure(by_id[tgt], rel, by_id, seen)
    return seen

def check(graph, by_id):
    errs = 0
    for n in graph:
        for rel in ALL_REL_KEYS:
            v = n.get(rel)
            if v is None:
                continue
            items = v if isinstance(v, list) else [v]
            for it in items:
                tid = it.get("id") if isinstance(it, dict) else it
                if tid not in by_id:
                    print(f"ERROR 悬空引用: {n['id']} --{rel}--> {tid}"); errs += 1
        mx = n.get("mutuallyExclusiveWith")
        if mx:
            items = mx if isinstance(mx, list) else [mx]
            for it in items:
                tid = it.get("id") if isinstance(it, dict) else it
                if tid in by_id and n["id"] in (by_id[tid].get("mutuallyExclusiveWith") or []):
                    if n["id"] < tid:  # 只报一次
                        print(f"ERROR 互斥不自反对称: {n['id']} <-> {tid}"); errs += 1
    print(f"CHECK {'FAIL' if errs else 'OK'} nodes={len(graph)} errors={errs}")
    sys.exit(1 if errs else 0)

def show_concept(name, by_id, by_name):
    n = by_name.get(name)
    if not n:
        print(f"NOT_FOUND: {name}"); sys.exit(1)
    print(f"# {n.get('name')} [{n.get('type','?')}]")
    print(f"{n.get('definition','')}\nsource: {n.get('source','-')}")
    for rel in ALL_REL_KEYS:
        v = n.get(rel)
        if v:
            items = v if isinstance(v, list) else [v]
            labels = [ (by_id.get(i.get('id') if isinstance(i, dict) else i, {}).get('name', i.get('id') if isinstance(i, dict) else i) ) for i in items ]
            deg = [f"{l}(degree={i.get('degree')},source={i.get('source','-')})" if isinstance(i, dict) and 'degree' in i else (f"{l}(source={i.get('source','-')})" if isinstance(i, dict) else l) for l, i in zip(labels, items)]
            print(f"{rel}: {', '.join(deg)}")
    inv = []
    for m in by_id.values():
        for rel in REL_KEYS:
            v = m.get(rel)
            items = v if isinstance(v, list) else ([v] if v else [])
            for it in items:
                if (it.get("id") if isinstance(it, dict) else it) == n["id"]:
                    inv.append(f"{m.get('name')} --{rel}-->")
        for rel in [REQ_REL, "supportedBy", "evaluatedBy"]:
            v = m.get(rel)
            if not v:
                continue
            items = v if isinstance(v, list) else [v]
            for it in items:
                if (it.get("id") if isinstance(it, dict) else it) == n["id"]:
                    inv.append(f"{m.get('name')} --{rel}-->")
    if inv:
        print("入边: " + "; ".join(inv))

def build_undirected_adj(by_id):
    adj = {nid: [] for nid in by_id}
    for n in by_id.values():
        for rel in ALL_REL_KEYS + ["evaluatedBy"]:
            v = n.get(rel)
            if v is None:
                continue
            items = v if isinstance(v, list) else [v]
            for it in items:
                tid = it.get("id") if isinstance(it, dict) else it
                if tid and tid in by_id and tid != n["id"]:
                    adj[n["id"]].append((tid, rel))
                    adj[tid].append((n["id"], rel))
    return adj

def shortest_path(name_a, name_b, by_id, by_name):
    a = by_name.get(name_a)
    b = by_name.get(name_b)
    if not a or not b:
        print(f"NOT_FOUND: A={name_a} found={bool(a)} B={name_b} found={bool(b)}")
        sys.exit(2)
    aid, bid = a["id"], b["id"]
    if aid == bid:
        print(f"PATH: {name_a}")
        return
    adj = build_undirected_adj(by_id)
    q = deque([(aid, [aid])])
    visited = {aid}
    while q:
        cur, path = q.popleft()
        for nxt, rel in adj[cur]:
            if nxt in visited:
                continue
            visited.add(nxt)
            new_path = path + [(rel, nxt)]
            if nxt == bid:
                # 输出路径与关系序列
                out = [by_id[aid].get("name", aid)]
                for rel, nid in new_path[1:]:
                    out.append(f"--[{rel}]-->")
                    out.append(by_id[nid].get("name", nid))
                print("PATH: " + " ".join(out))
                return
            q.append((nxt, new_path))
    print(f"NO_PATH: {name_a} <-> {name_b}")

def stats(graph, by_id):
    type_counts = Counter()
    edge_counts = Counter()
    total_edges = 0
    for n in graph:
        type_counts[n.get("type", "?").split(":")[-1]] += 1
        for rel in ALL_REL_KEYS + ["evaluatedBy"]:
            v = n.get(rel)
            if v is None:
                continue
            items = v if isinstance(v, list) else [v]
            cnt = len(items)
            edge_counts[rel] += cnt
            total_edges += cnt
    print("# 图谱统计")
    print(f"total_nodes={len(graph)} total_edges={total_edges}")
    print("nodes_by_type:")
    for t, c in type_counts.most_common():
        print(f"  {t}: {c}")
    print("edges_by_relation:")
    for rel, c in edge_counts.most_common():
        print(f"  {rel}: {c}")

def judge(sname, sysname, graph, by_id, by_name, rules, explain=False):
    sc, sy = by_name.get(sname), by_name.get(sysname)
    if not sc or not sy:
        print(f"NOT_FOUND: scenario={sname} found={bool(sc)} system={sysname} found={bool(sy)}")
        sys.exit(2)
    reqs = sc.get(REQ_REL, [])
    expanded = set()
    expansion_log = {}
    for r in reqs:
        rid = r.get("id") if isinstance(r, dict) else r
        expanded.add(rid)
        if rid in by_id:
            impl = closure(by_id[rid], "implies", by_id)
            if impl:
                expansion_log[rid] = sorted(impl)
            expanded |= impl
    caps = {}
    cap_meta = {}
    for c in sy.get("supportedBy", []):
        cid = c.get("id")
        caps[cid] = c.get("degree", "native")
        cap_meta[cid] = c
    verdicts = []
    mutex_pairs = []
    exp_list = sorted(expanded)
    if explain:
        print(f"# 判定依据展开: {sname} × {sysname}")
        print(f"场景直接需求 ({len(reqs)} 个概念):")
        for r in reqs:
            rid = r.get("id") if isinstance(r, dict) else r
            rn = by_id.get(rid)
            print(f"  - {rn.get('name') if rn else rid}")
        if expansion_log:
            print("蕴含闭包展开:")
            for rid, impls in expansion_log.items():
                rn = by_id.get(rid)
                print(f"  {rn.get('name') if rn else rid} implies -> {', '.join(by_id[i].get('name', i) for i in impls)}")
    for rid in exp_list:
        rn = by_id.get(rid)
        if not rn:
            continue
        deg = caps.get(rid)
        status = { "native": "SUPPORTED", "config": "SUPPORTED", "app-level": "SUPPORTED_WITH_APP_EFFORT", "none": "MISSING" }.get(deg, "MISSING")
        verdicts.append((rid, rn.get("name"), status, deg))
        for mx in (rn.get("mutuallyExclusiveWith") or []):
            mxid = mx.get("id") if isinstance(mx, dict) else mx
            if mxid in expanded:
                pair = tuple(sorted([rid, mxid]))
                if pair not in mutex_pairs:
                    mutex_pairs.append(pair)
    print(f"# 判定: {sname} × {sysname}")
    for rid, name, status, deg in verdicts:
        meta = cap_meta.get(rid, {})
        detail = f"degree={deg}" if deg else "无能力边"
        if explain and meta:
            detail += f", source={meta.get('source','-')}"
        print(f"  {status:24s} {name} ({detail})")
    if mutex_pairs:
        for a, b in mutex_pairs:
            print(f"  CONFLICT {by_id[a].get('name')} ⟂ {by_id[b].get('name')}")
        sys.exit(1)
    missing = [v for v in verdicts if v[2] == "MISSING"]
    if missing:
        print(f"VERDICT: MISSING {len(missing)}/{len(verdicts)}")
        sys.exit(1)
    print(f"VERDICT: SUPPORTED ({len(verdicts)} 概念全适配，含蕴含闭包)")

def main():
    args = sys.argv[1:]
    graph, rules = load()
    by_id, by_name = index(graph)
    if not args or args[0] == "--check":
        check(graph, by_id)
    elif args[0] == "--concept" and len(args) > 1:
        show_concept(args[1], by_id, by_name)
    elif args[0] == "--path" and len(args) == 3:
        shortest_path(args[1], args[2], by_id, by_name)
    elif args[0] == "--stats":
        stats(graph, by_id)
    elif args[0] == "--judge" and "--scenario" in args and "--system" in args:
        explain = "--explain" in args
        judge(args[args.index("--scenario")+1], args[args.index("--system")+1], graph, by_id, by_name, rules, explain=explain)
    else:
        print("用法: kg-query.py [--check | --stats | --concept <名> | --path <A> <B> | --judge --scenario <名> --system <名> [--explain]]")
        sys.exit(2)

if __name__ == "__main__":
    main()
