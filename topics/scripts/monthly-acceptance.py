#!/usr/bin/env python3
# 月度验收汇总生成（批次197，对齐 BufferCache L4 层）
# 用法: monthly-acceptance.py [YYYY-MM]（默认当月）
# 数据源: Testing/self-check-history.log（E0）/ results/<pkg>-<date>/SUMMARY.json（周期任务）
#         / topics/scripts/test-registry.tsv（verified 流转快照，环比）/ ROADMAP 主控执行队列（用户门）
# 产物: results/acceptance-YYYY-MM.md（results/ gitignore 本地件，摘要行入 CHANGELOG[EXEC]）
# 判定: 周期覆盖率 = 实跑包数 / 应跑包数（nightly=每日，weekly=每周一）≥80% = 本月验收通过；
#       连续两月 <80% → 报告标注升级人审（BufferCache L4 口径移植）
import calendar, json, os, re, sys, datetime

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
MONTH = sys.argv[1] if len(sys.argv) > 1 else datetime.date.today().strftime("%Y-%m")
y, m = map(int, MONTH.split("-"))
today = datetime.date.today()
is_current = (MONTH == today.strftime("%Y-%m"))
days_in_month = today.day if is_current else calendar.monthrange(y, m)[1]
mondays = sum(1 for d in range(1, days_in_month + 1) if datetime.date(y, m, d).weekday() == 0)

lines = [f"# 月度验收报告 {MONTH}", ""]
lines.append(f"> 生成：{datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}（批次197 工具；数据源=self-check-history.log + results/<pkg>-<date>/SUMMARY.json + test-registry.tsv + ROADMAP 主控队列）")
lines.append("")

# ---- L1 门禁 ----
e0_total = e0_last = "-"; e0_err = e0_warn = 0; e0_n = 0
try:
    rows = []
    with open("Testing/self-check-history.log", encoding="utf-8") as f:
        for ln in f:
            if ln.startswith("#") or not ln.strip():
                continue
            p = ln.rstrip("\n").split("\t")
            if len(p) >= 5 and p[0][:7] == MONTH:
                rows.append(p)
    e0_n = len(rows)
    if rows:
        e0_err = sum(int(r[1]) for r in rows); e0_warn = sum(int(r[2]) for r in rows)
        e0_total = f"{rows[-1][3]}（{rows[-1][4]}，{len(rows[-1][1]) and rows[-1][0]}）"
except FileNotFoundError:
    pass
lines += ["## 1. L1 门禁（E0 十三步）", "",
          f"- 当月运行 **{e0_n}** 次，累计 error={e0_err} / warn={e0_warn}", f"- 最新：{e0_total}", ""]

# ---- 周期任务 ----
def agg(pkg):
    runs = []
    for d in os.listdir("results"):
        if d.startswith(pkg + "-") and os.path.isfile(f"results/{d}/SUMMARY.json"):
            date = d[len(pkg) + 1:]
            if date[:7] == MONTH:
                s = json.load(open(f"results/{d}/SUMMARY.json", encoding="utf-8"))
                runs.append((date, s))
    runs.sort()
    t = sum(s["total"] for _, s in runs); p = sum(s["pass"] for _, s in runs)
    f_ = sum(s["fail"] for _, s in runs)
    return runs, t, p, f_

lines += ["## 2. 周期任务覆盖（hermes cron：nightly 每日 / weekly 每周一）", ""]
exp = days_in_month + mondays
act = tot = pas = fai = 0
for pkg, e in (("nightly", days_in_month), ("weekly", mondays)):
    runs, t, p, f_ = agg(pkg)
    act += len(runs); tot += t; pas += p; fai += f_
    det = "; ".join(f"{d} {s['pass']}/{s['total']}" + (f" FAIL={s['fail']}" if s["fail"] else "") for d, s in runs) or "无执行记录"
    lines.append(f"- {pkg}：实跑 {len(runs)}/{e} 应跑；用例 pass={p} total={t}" + (f" **FAIL={f_}**" if f_ else "") + f"（{det}）")
cov = act / exp if exp else 0
lines += ["", f"- 周期覆盖率：**{act}/{exp} = {cov*100:.0f}%**（≥80% 为验收通过线）", ""]
if fai:
    lines += ["### 失败明细", ""]
    for pkg in ("nightly", "weekly"):
        for d, s in agg(pkg)[0]:
            if s["fail"]:
                lines.append(f"- {pkg} {d}：FAIL={s['fail']}（见 results/{pkg}-{d}/）")
    lines.append("")

# ---- verified 流转 ----
reg = os.path.join("topics", "scripts", "test-registry.tsv")
status = {}
with open(reg, encoding="utf-8") as f:
    for ln in f:
        if ln.startswith("#") or not ln.strip():
            continue
        p = ln.rstrip("\n").split("\t")
        if len(p) >= 6:
            status[p[5]] = status.get(p[5], 0) + 1
prev_verified = None
for mm in range(m - 1, 0, -1):
    p = f"results/acceptance-{y:04d}-{mm:02d}.md"
    if os.path.isfile(p):
        mt = re.search(r"verified=(\d+)", open(p, encoding="utf-8").read())
        if mt:
            prev_verified = int(mt.group(1))
        break
ver = status.get("verified", 0)
delta = f"（环比 {'+' if ver >= (prev_verified or 0) else ''}{ver - (prev_verified or 0)}）" if prev_verified is not None else "（首月快照，无环比）"
lines += ["## 3. 用例状态分布（registry）", "",
          f"- mapped={status.get('mapped',0)} / pending={status.get('pending',0)} / verified={ver}{delta} / blocked={status.get('blocked',0)}", ""]

# ---- 用户门/挂起 ----
lines += ["## 4. 用户门与挂起（ROADMAP 主控执行队列）", ""]
gates = []
try:
    txt = open("topics/ROADMAP.md", encoding="utf-8").read()
    sec = txt.split("## 主控执行队列")[1].split("## ")[0]
    for ln in sec.splitlines():
        if ln.startswith("|") and "----" not in ln:
            cells = [c.strip() for c in ln.strip("|").split("|")]
            if len(cells) >= 3 and cells[0] != "序":
                st = cells[2]
                if ("用户" in st or "挂起" in st or "待" in st) and "✅" not in st:
                    gates.append(f"- {cells[1]}：{st}（负责={cells[3] if len(cells)>3 else '-'}）")
except (IndexError, FileNotFoundError):
    pass
lines += (gates or ["- （无）"]) + [""]

# ---- 判定 ----
prev_low = False
for mm in range(m - 1, 0, -1):
    p = f"results/acceptance-{y:04d}-{mm:02d}.md"
    if os.path.isfile(p):
        prev_low = "覆盖率：**" in open(p, encoding="utf-8").read() and re.search(r"覆盖率：\*\*\d+/\d+ = (\d+)%\*\*", open(p, encoding="utf-8").read()) and int(re.search(r"覆盖率：\*\*\d+/\d+ = (\d+)%\*\*", open(p, encoding="utf-8").read()).group(1)) < 80
        break
verdict = "通过" if cov >= 0.8 else "不通过"
if cov < 0.8 and prev_low:
    verdict += "；**连续两月 <80% → 升级人审**"
lines += ["## 5. 验收判定", "",
          f"- 周期覆盖率 {cov*100:.0f}%（{act}/{exp}）→ 本月验收 **{verdict}**",
          f"- verified={ver}（快照锚，供次月环比）", "",
          "## 6. 缺口与下月计划", ""]
gaps = []
if fai:
    gaps.append(f"- 周期任务存在 FAIL={fai} 项，按 TEST-16 闭环处置")
if e0_err:
    gaps.append(f"- E0 当月累计 error={e0_err}，逐条回溯")
if not gates or gates == ["- （无）"]:
    gaps.append("- 用户门清零（H3 --live 待约见外无挂账）" )
if not gaps:
    gaps.append("- 无显性缺口；滚动项按 TEST-16 时刻表执行")
lines += gaps + [""]

out = f"results/acceptance-{MONTH}.md"
os.makedirs("results", exist_ok=True)
with open(out, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print(f"ACCEPTANCE_OK {out} coverage={cov*100:.0f}% verdict={verdict}")
