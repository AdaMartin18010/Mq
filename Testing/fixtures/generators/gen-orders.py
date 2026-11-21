#!/usr/bin/env python3
"""订单场景测试数据生成器（契约语义测试 03-业务场景/01-order-lifecycle 对齐）"""
import sys, json, uuid, random
random.seed(20261121)  # 金样本固定种子: 矩阵可复现 (批次190)

BOUNDARY = [
    {"orderId": "", "note": "空订单号-非法输入"},                        # 边界：空键
    {"items": [], "note": "空明细"},                                     # 边界：空数组
    {"totalAmount": 0, "note": "零金额"},
    {"totalAmount": 99999999.99, "note": "极大金额"},
    {"orderId": "ORD-" + "9" * 64, "note": "超长订单号(64字符)"},
    {"items": [{"sku": "测试商品-Ω≈ç√", "qty": 1}], "note": "Unicode 商品名"},
]

def gen(n):
    events = []
    for b in BOUNDARY:
        events.append({"_headers": {"trace-id": str(uuid.uuid4()), "idempotency-key": str(uuid.uuid4())},
                       "type": "OrderCreateCmd", "boundary": True, **{k: v for k, v in b.items() if k != "note"},
                       "_note": b.get("note", "")})
    for _ in range(n):
        oid = f"ORD-{random.randint(10**9, 10**10)}"
        events.append({"_headers": {"trace-id": str(uuid.uuid4()), "idempotency-key": str(uuid.uuid4())},
                       "type": "OrderCreateCmd", "orderId": oid,
                       "items": [{"sku": f"SKU-{random.randint(1,500)}", "qty": random.randint(1,9)}],
                       "totalAmount": round(random.uniform(1, 9999), 2)})
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
