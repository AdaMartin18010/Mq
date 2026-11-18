#!/usr/bin/env python3
# 场景包→集成矩阵 自动映射校验（挂账#2）
# 读 Testing/06-契约语义测试/03-业务场景/*/SEMANTICS.md 的 x-semantics 维度
# 与 contract.yaml 主系统 → 校验对应矩阵格存在 → 生成/更新 场景映射.md
import os, re, sys, csv

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SC = os.path.join(ROOT, "Testing", "06-契约语义测试", "03-业务场景")
MAT = os.path.join(ROOT, "Testing", "07-集成矩阵", "matrix-registry.tsv")

# 场景主系统（07 README 映射节的手工约定 → 机读化）
PRIMARY = {
    "01-order-lifecycle": ("KAFKA", ["DLV", "ORD", "IDM", "DLQ", "TRX"]),
    "02-payment-reconciliation": ("KAFKA", ["DLV", "IDM", "PST", "ORD"]),
    "03-inventory": ("KAFKA", ["TRX", "IDM", "ORD", "BCK", "TTL"]),
    "04-notification": ("RABBITMQ", ["FLT", "PST", "RET", "DLQ"]),
    "05-iot-telemetry": ("MQTT", ["DLV", "TTL", "FLW", "BCK"]),
    "06-cdc-sync": ("KAFKA", ["ORD", "PST", "IDM", "BCK"]),
    "07-audit-trail": ("PULSAR", ["PST", "ORD", "DLV"]),
    "08-task-queue": ("NATS", ["RET", "DLQ", "DLY", "IDM"]),
}
DIM2FEAT = {"交付语义":"DLV","顺序性":"ORD","幂等去重":"IDM","重试退避":"RET","死信":"DLQ","事务":"TRX",
            "背压":"BCK","TTL过期":"TTL","延迟消息":"DLY","消息过滤":"FLT","流控":"FLW","持久化":"PST"}

cells = set()
with open(MAT, encoding="utf-8") as f:
    for line in f:
        if line.startswith("#") or not line.strip() or line.startswith("case_id"): continue
        c = line.rstrip("\r\n").split("\t")
        cells.add((c[1], c[3]))

fails, lines = [], ["# 场景包 → 集成矩阵 映射（机读生成，勿手改——改 SEMANTICS.md 后重跑 scenario-map.py）", ""]
for scen, (sys_, feats) in PRIMARY.items():
    sem = os.path.join(SC, scen, "SEMANTICS.md")
    decl = set()
    if os.path.isfile(sem):
        for m in re.finditer(r"x-semantics:\s*\[([^\]]+)\]", open(sem, encoding="utf-8").read()):
            for d in m.group(1).split(","):
                d = d.strip().strip('"').strip("'")
                if d in DIM2FEAT: decl.add(DIM2FEAT[d])
    union = sorted(set(feats) | decl)
    lines.append(f"## {scen}（主系统 {sys_}）")
    for ft in union:
        ok = (sys_, ft) in cells
        mark = "✅" if ok else "❌"
        if not ok: fails.append(f"{scen}: {sys_}×{ft} 矩阵格缺失")
        lines.append(f"- {mark} {sys_} × {ft}")
    lines.append("")
open(os.path.join(ROOT, "Testing", "07-集成矩阵", "场景映射.md"), "w", encoding="utf-8", newline="\n").write("\n".join(lines))
print("\n".join(fails) if fails else "SCENARIO_MAP OK（全部映射格存在）")
sys.exit(1 if fails else 0)
