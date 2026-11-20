#!/usr/bin/env python3
"""库存场景测试数据生成器（契约语义测试 03-业务场景/03-inventory 对齐，批次187 金样本扩展）"""
import sys, json, uuid, random

BOUNDARY = [
    {"reservationId": "", "note": "空预留单号-幂等键非法"},
    {"sku": "", "note": "空 SKU"},
    {"quantity": 0, "note": "零数量预留"},
    {"quantity": 10**12, "note": "极大数量"},
    {"ttlSeconds": 0, "note": "TTL=0 即时过期边界（T.14）"},
    {"sku": "预留商品-Ω≈ç√", "note": "Unicode 商品名"},
]

def gen(n):
    events = []
    for b in BOUNDARY:
        events.append({"_headers": {"trace-id": str(uuid.uuid4()), "idempotency-key": str(uuid.uuid4())},
                       "type": "ReserveStockCmd", "boundary": True, **{k: v for k, v in b.items() if k != "note"},
                       "_note": b.get("note", "")})
    for _ in range(n):
        events.append({"_headers": {"trace-id": str(uuid.uuid4()), "idempotency-key": str(uuid.uuid4())},
                       "type": "ReserveStockCmd",
                       "reservationId": f"RSV-{random.randint(10**9, 10**10)}",
                       "sku": f"SKU-{random.randint(1, 500)}",
                       "quantity": random.randint(1, 50),
                       "orderId": f"ORD-{random.randint(10**9, 10**10)}",
                       "ttlSeconds": random.choice([30, 60, 300, 3600])})
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
