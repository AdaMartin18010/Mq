#!/usr/bin/env python3
"""审计留痕场景测试数据生成器（契约语义测试 03-业务场景/07-audit-trail 对齐，批次187 金样本扩展）"""
import sys, json, uuid, random, hashlib
random.seed(20261121)  # 金样本固定种子: 矩阵可复现 (批次190)
from datetime import datetime, timezone

ACTIONS = ["order.create", "order.cancel", "stock.reserve", "user.login", "admin.grant"]

def now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

def fingerprint(prev, record):
    base = prev + json.dumps({k: v for k, v in record.items() if k not in ("prevHash", "integrityHash")},
                             sort_keys=True, ensure_ascii=False)
    return hashlib.sha256(base.encode("utf-8")).hexdigest()

BOUNDARY = [
    {"actor": "", "action": "order.create", "note": "空操作者 who 缺失"},
    {"actor": "svc-order", "action": "", "note": "空操作类型 what 缺失"},
    {"actor": "svc-order", "action": "order.create", "targetRef": "", "note": "空对象引用"},
    {"actor": "审计者-Ω≈ç√", "action": "admin.grant", "targetRef": "user-1",
     "note": "Unicode 操作者（编码差异探针）"},
    {"actor": "svc-order", "action": "order.create", "targetRef": "x" * 256,
     "note": "超长对象引用（256 字符）"},
]

def gen(n):
    events = []
    prev = ""
    for b in BOUNDARY:
        rec = {"auditId": str(uuid.uuid4()), "actor": b.get("actor", ""),
               "action": b.get("action", ""), "targetRef": b.get("targetRef", "obj-1"),
               "occurredAt": now_iso(), **{k: v for k, v in b.items() if k not in ("note", "actor", "action", "targetRef")}}
        rec["prevHash"] = prev
        rec["integrityHash"] = fingerprint(prev, rec)
        rec["_note"] = b.get("note", "")
        rec["boundary"] = True
        prev = rec["integrityHash"]
        events.append({"_headers": {"trace-id": str(uuid.uuid4())}, "type": "AuditRecordEvent", **rec})
    for _ in range(n):
        rec = {"auditId": str(uuid.uuid4()), "actor": f"svc-{random.choice(['order','stock','user'])}",
               "action": random.choice(ACTIONS), "targetRef": f"obj-{random.randint(10**6, 10**7)}",
               "occurredAt": now_iso()}
        rec["prevHash"] = prev
        rec["integrityHash"] = fingerprint(prev, rec)
        prev = rec["integrityHash"]
        events.append({"_headers": {"trace-id": str(uuid.uuid4())}, "type": "AuditRecordEvent", **rec})
    return events

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--validate":
        evs = gen(0)
        covered = [e.get("_note", "") for e in evs]
        assert len(covered) == len(BOUNDARY), "边界值缺失"
        chain = [e for e in evs]
        ok = all(chain[i]["prevHash"] == chain[i - 1]["integrityHash"] for i in range(1, len(chain)))
        assert ok, "链式完整性断裂"
        print(f"VALIDATE_OK boundary_cases={len(covered)} chain_integrity=OK")
        sys.exit(0)
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    for e in gen(n):
        print(json.dumps(e, ensure_ascii=False))
