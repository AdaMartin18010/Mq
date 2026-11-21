#!/usr/bin/env python3
# 动态验证③：契约边界复算（批次196）——金样本生成器种子确定性 + 关键边界探针在位
# 复算面：① 8 生成器双跑数值负载全等（uuid 类字段不参与，钉 random.seed=批次189 设计）
#        ② 精度探针 quantity=10**18+7（inventory）与 TTL=0 边界（ttlSeconds）在位
# RC: 0=全过；1=存在漂移/探针缺失
import json, subprocess, sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
GEN = os.path.join(ROOT, "Testing", "fixtures", "generators")
GENS = ["gen-audit-trail.py", "gen-cdc-sync.py", "gen-inventory.py", "gen-iot-telemetry.py",
        "gen-notification.py", "gen-orders.py", "gen-payments.py", "gen-task-queue.py"]
IDISH = ("id", "Id", "key", "hash")  # id/key/hash 字段：uuid 或墙钟链式哈希（audit 链设计=批次188），不可种子化，跳过比对
import re
TS_NAME = re.compile(r"(ts|time|at$|created|updated|enqueued|occurred|received|deadline)", re.I)
TS_VAL = re.compile(r"^\d{4}-\d{2}-\d{2}[T ]")  # ISO 时间串=墙钟字段，双跑必然不等，非种子漂移
UUID_VAL = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", re.I)  # blob://<uuid> 等内嵌形态

def run(gen):
    r = subprocess.run([sys.executable, os.path.join(GEN, gen)], capture_output=True, text=True, cwd=GEN, timeout=60)
    if r.returncode != 0:
        raise RuntimeError(f"{gen} RC={r.returncode}: {r.stderr[:120]}")
    return [json.loads(l) for l in r.stdout.splitlines() if l.strip()]

def payload(rows):
    out = []
    for ev in rows:
        keep = {}
        for k, v in ev.items():
            if any(t.lower() in k.lower() for t in IDISH):
                continue
            if isinstance(v, dict):  # _headers 等 uuid 元数据
                continue
            if TS_NAME.search(k) or (isinstance(v, str) and (TS_VAL.match(v) or UUID_VAL.search(v))):
                continue  # 墙钟时间/uuid 内嵌字段：非种子化，不参与确定性比对
            keep[k] = v
        out.append(keep)
    return out

errs = []
for g in GENS:
    try:
        a, b = payload(run(g)), payload(run(g))
        if a != b:
            diffs = sum(1 for x, y in zip(a, b) if x != y)
            errs.append(f"{g} 种子漂移（{diffs} 事件数值不等）")
    except RuntimeError as e:
        errs.append(str(e))

# 探针在位
try:
    inv = payload(run("gen-inventory.py"))
    if not any(e.get("quantity") == 10**18 + 7 for e in inv):
        errs.append("inventory 缺精度探针 quantity=10**18+7")
    if not any(e.get("ttlSeconds") == 0 for e in inv):
        errs.append("inventory 缺 TTL=0 边界探针")
except RuntimeError as e:
    errs.append(str(e))

if errs:
    print("BOUNDARY_FAIL " + "; ".join(errs))
    sys.exit(1)
print("BOUNDARY_OK 8 生成器双跑数值全等 + 精度/TTL 探针在位")
sys.exit(0)
