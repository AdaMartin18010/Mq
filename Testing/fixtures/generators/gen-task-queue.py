#!/usr/bin/env python3
"""任务队列场景测试数据生成器（契约语义测试 03-业务场景/08-task-queue 对齐，批次187 金样本扩展）"""
import sys, json, uuid, random, time
from datetime import datetime, timezone

TASK_TYPES = ["render", "transcode", "notify-digest", "export", "ml-inference"]

def iso(ms):
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

NOW_MS = lambda: int(time.time() * 1000)

BOUNDARY = [
    {"taskId": "", "note": "空任务 ID-幂等键非法"},
    {"taskType": "render", "retryBudget": 0, "note": "重试额度=0 不再重试"},
    {"taskType": "render", "retryBudget": -1, "note": "负重试额度-非法输入"},
    {"taskType": "render", "deadline": iso(NOW_MS() - 3600_000), "note": "截止已过-逾期执行无意义"},
    {"taskType": "", "note": "空任务类型"},
    {"taskType": "渲染任务-Ω≈ç√", "note": "Unicode 任务类型（编码差异探针）"},
]

def gen(n):
    events = []
    for b in BOUNDARY:
        rec = {"taskId": b.get("taskId", f"TSK-{random.randint(10**9, 10**10)}"),
               "taskType": b.get("taskType", "render"),
               "payloadRef": f"blob://{uuid.uuid4()}",
               "deadline": iso(NOW_MS() + random.choice([60_000, 600_000, 3600_000])),
               "retryBudget": 3}
        rec.update({k: v for k, v in b.items() if k not in ("note",)})
        rec["_note"] = b.get("note", "")
        rec["boundary"] = True
        events.append({"_headers": {"trace-id": str(uuid.uuid4())}, "type": "TaskEnvelope", **rec})
    for _ in range(n):
        done = random.random() < 0.7
        if done:
            events.append({"_headers": {"trace-id": str(uuid.uuid4())},
                           "type": "TaskCompletedEvent",
                           "taskId": f"TSK-{random.randint(10**9, 10**10)}",
                           "completedAt": iso(NOW_MS()), "resultRef": f"blob://{uuid.uuid4()}"})
        else:
            events.append({"_headers": {"trace-id": str(uuid.uuid4())},
                           "type": "TaskFailedEvent",
                           "taskId": f"TSK-{random.randint(10**9, 10**10)}",
                           "failReason": random.choice(["timeout", "worker-crash", "payload-corrupt"]),
                           "retryable": random.choice([True, False])})
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
