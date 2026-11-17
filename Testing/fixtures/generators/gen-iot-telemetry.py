#!/usr/bin/env python3
"""IoT 遥测场景测试数据生成器（03-业务场景/05-iot-telemetry 对齐）"""
import sys, json, uuid, random, time

METRICS = [("temperature", -40, 125, "°C"), ("pressure", 0, 1000, "kPa"), ("humidity", 0, 100, "%")]

BOUNDARY = [
    {"value": -41, "note": "温度超下限-传感器故障域"},
    {"value": 126, "note": "温度超上限"},
    {"collectedAt_offset_s": -3600, "note": "时间戳漂移-设备时钟回拨 1h"},
    {"collectedAt_offset_s": 3600, "note": "时间戳漂移-未来 1h"},
]

def gen(n):
    now = int(time.time())
    evs = []
    for b in BOUNDARY:
        off = b.get("collectedAt_offset_s", 0)
        evs.append({"_headers": {"trace-id": str(uuid.uuid4())},
                    "type": "TelemetryReadingEvent", "deviceId": f"dev-{uuid.uuid4().hex[:8]}",
                    "siteId": f"site-{random.randint(1,99)}", "metric": "temperature",
                    "value": b.get("value", 25.0),
                    "collectedAt": now + off, "_note": b.get("note", ""), "boundary": True})
    for _ in range(n):
        m, lo, hi, _ = random.choice(METRICS)
        evs.append({"_headers": {"trace-id": str(uuid.uuid4())},
                    "type": "TelemetryReadingEvent", "deviceId": f"dev-{uuid.uuid4().hex[:8]}",
                    "siteId": f"site-{random.randint(1,99)}", "metric": m,
                    "value": round(random.uniform(lo, hi), 2),
                    "collectedAt": now - random.randint(0, 600)})  # 常态：近 10 分钟内
    random.shuffle(evs)  # 模拟弱网乱序
    return evs

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--validate":
        evs = gen(0)
        assert len(evs) == len(BOUNDARY), "边界值缺失"
        print(f"VALIDATE_OK boundary_cases={len(evs)}")
        sys.exit(0)
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    for e in gen(n):
        print(json.dumps(e, ensure_ascii=False))
