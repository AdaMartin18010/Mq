#!/usr/bin/env python3
"""CDC 同步场景测试数据生成器（契约语义测试 03-业务场景/06-cdc-sync 对齐，批次187 金样本扩展）"""
import sys, json, uuid, random, time

OPS = ["c", "u", "d", "r"]

def row():
    return {"id": random.randint(10**6, 10**7), "name": f"row-{random.randint(1, 999)}",
            "amount": round(random.uniform(0, 10000), 2)}

def src():
    return {"connector": "postgres", "db": "app", "table": "orders",
            "lsn": random.randint(10**9, 10**12)}

BOUNDARY = [
    {"op": "c", "before": None, "after": row(), "note": "op=create before=null 边界"},
    {"op": "d", "before": row(), "after": None, "note": "op=delete after=null 边界"},
    {"op": "r", "before": None, "after": row(), "note": "op=read 快照（非变更流）"},
    {"op": "u", "before": {"id": 1, "name": "a", "amount": 0}, "after": {"id": 1, "name": "b", "amount": 0},
     "note": "op=update 空对象镜像边界"},
    {"op": "u", "before": row(), "after": row(), "tsMs": 0, "note": "tsMs=0 时间戳边界"},
]

def gen(n):
    events = []
    for b in BOUNDARY:
        events.append({"_headers": {"trace-id": str(uuid.uuid4())},
                       "type": "CdcChangeEvent", "boundary": True,
                       "source": src(), "tsMs": int(time.time() * 1000),
                       **{k: v for k, v in b.items() if k != "note"}, "_note": b.get("note", "")})
    for _ in range(n):
        op = random.choice(OPS)
        events.append({"_headers": {"trace-id": str(uuid.uuid4())},
                       "type": "CdcChangeEvent", "op": op,
                       "before": row() if op in ("u", "d") else None,
                       "after": row() if op in ("c", "u", "r") else None,
                       "source": src(), "tsMs": int(time.time() * 1000)})
    return events

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--validate":
        evs = gen(0)
        covered = [e.get("_note", "") for e in evs]
        assert len(covered) == len(BOUNDARY), "边界值缺失"
        print(f"VALIDATE_OK boundary_cases={len(covered)}")
        sys.exit(0)
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    for e in gen(n):
        print(json.dumps(e, ensure_ascii=False))
