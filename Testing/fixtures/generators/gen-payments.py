#!/usr/bin/env python3
"""支付场景测试数据生成器（03-业务场景/02-payment-reconciliation 对齐）"""
import sys, json, uuid, random
random.seed(20261121)  # 金样本固定种子: 矩阵可复现 (批次190)

CURRENCIES = ["CNY", "USD", "EUR"]

BOUNDARY = [
    {"amount": 0, "note": "零金额-合法(退款场景)"},
    {"amount": -1, "note": "负金额-非法输入"},
    {"amount": 999999999.99, "note": "极大金额"},
    {"currency": "XXX", "note": "非法币种-应被契约拒绝"},
]

def gen(n):
    evs = []
    for b in BOUNDARY:
        evs.append({"_headers": {"trace-id": str(uuid.uuid4()), "idempotency-key": str(uuid.uuid4())},
                    "type": "PaymentInitiatedCmd", "paymentId": f"PAY-{uuid.uuid4().hex[:12]}",
                    **{k: v for k, v in b.items() if k != "note"},
                    "accountRef": "acct:***MASKED***", "_note": b.get("note", ""), "boundary": True})
    for _ in range(n):
        evs.append({"_headers": {"trace-id": str(uuid.uuid4()), "idempotency-key": str(uuid.uuid4())},
                    "type": "PaymentInitiatedCmd", "paymentId": f"PAY-{uuid.uuid4().hex[:12]}",
                    "amount": round(random.uniform(0.01, 50000), 2),
                    "currency": random.choice(CURRENCIES),
                    "accountRef": "acct:***MASKED***"})
    return evs

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--validate":
        evs = gen(0)
        assert all("_note" in e for e in evs), "边界值缺失"
        print(f"VALIDATE_OK boundary_cases={len(evs)}")
        sys.exit(0)
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    for e in gen(n):
        print(json.dumps(e, ensure_ascii=False))
