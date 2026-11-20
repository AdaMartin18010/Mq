#!/usr/bin/env python3
"""通知场景测试数据生成器（契约语义测试 03-业务场景/04-notification 对齐，批次187 金样本扩展）"""
import sys, json, uuid, random
from datetime import datetime, timezone

CH = ["SMS", "EMAIL", "APP_PUSH", "WEBHOOK"]

def now_iso():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

BOUNDARY = [
    {"notifyId": "", "note": "空通知 ID"},
    {"channels": [], "note": "空通道数组-fan-out 无目标"},
    {"channels": ["SMS", "EMAIL", "APP_PUSH", "WEBHOOK"], "note": "全通道 fan-out（4 通道）"},
    {"contentRef": "", "note": "空内容引用-claim-check 缺失"},
    {"idempotencyKey": "", "note": "空幂等键"},
]

def gen(n):
    events = []
    for b in BOUNDARY:
        events.append({"_headers": {"trace-id": str(uuid.uuid4())},
                       "type": "NotificationRequestedCmd", "boundary": True,
                       **{k: v for k, v in b.items() if k != "note"}, "_note": b.get("note", "")})
    for _ in range(n):
        events.append({"_headers": {"trace-id": str(uuid.uuid4())},
                       "type": "NotificationDeliveredEvent",
                       "notifyId": f"NTF-{random.randint(10**9, 10**10)}",
                       "channel": random.choice(CH), "deliveredAt": now_iso()})
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
