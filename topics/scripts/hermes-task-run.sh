#!/usr/bin/env bash
# hermes-task-run.sh — 确定性运行器: Testing/task-packages/<pkg>.yaml
# 用法: hermes-task-run.sh <nightly|weekly|pre-release>
#
# 语义（H5 周期常态化, 批次176 接线）:
#   - stdout: 无 FAIL 时**空输出**（no_agent cron 静默模式, 不投递）; 有 FAIL 时打印摘要行
#   - exit:   0=无 FAIL（PENDING/SKIP 允许）; 1=任一 FAIL 或 precheck 失败
#   - 产物:   results/<pkg>-<YYYY-MM-DD>/<ENV>-<case_id>.json（逐案）+ SUMMARY.json + 逐案 .log
#   - PENDING: spec 中 script="-" 的占位案（无脚本）, 只登记不判失败
#   - 日期:   产物目录用执行日（spec 内生成日仅历史锚, 不追随）
set -u
PKG="${1:?usage: hermes-task-run.sh <nightly|weekly|pre-release>}"
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" || exit 1
SPEC="Testing/task-packages/${PKG}.yaml"
if [ ! -f "$SPEC" ]; then echo "TASK-RUN FAIL pkg=$PKG spec_missing=$SPEC"; exit 1; fi

TODAY=$(date +%F)
OUT="results/${PKG}-${TODAY}"
mkdir -p "$OUT"
TS_ISO=$(date -u +%FT%TZ)

# ---- precheck（整体一次）
# RC 语义: 0=全环境可用 / 2=部分缺失按降级表继续（允许） / 3=E0 缺失整体阻塞
PRE="topics/scripts/hermes-env-precheck.sh"
if [ -f "$PRE" ]; then
  bash "$PRE" > "$OUT/precheck.log" 2>&1
  prec=$?
  if [ "$prec" -ne 0 ] && [ "$prec" -ne 2 ]; then
    echo "TASK-RUN FAIL pkg=$PKG date=$TODAY precheck_blocked rc=$prec (log: $OUT/precheck.log)"
    exit 1
  fi
fi

# ---- 解析 YAML -> TSV: env \t case_id \t script \t arg1..argN \t artifact_rel
python3 - "$SPEC" > "$OUT/.cases.tsv" <<'PYEOF'
import sys, re
spec = sys.argv[1]
env = None
cur = None          # [case_id, script, args[], artifact]
cases = []
def flush():
    global cur
    if cur and cur[0]:
        if not cur[3]:
            cur[3] = "{}-{}.json".format(env or "?", cur[0])
        cases.append([env or "?", cur[0], cur[1]] + cur[2] + [cur[3]])
    cur = None
for line in open(spec, encoding="utf-8"):
    raw = line.rstrip("\r\n")
    s = raw.strip()
    if not s or s.startswith("#"):
        continue
    if re.match(r"^artifacts:", raw):      # 顶层 artifacts 段(行首无缩进)才结束; case 级有缩进
        flush(); break
    m = re.match(r"-\s+name:\s*(\S+)", s)
    if m:
        flush(); env = m.group(1); continue
    m = re.match(r"-\s+id:\s*(\S+)", s)
    if m:
        flush()
        cur = [m.group(1), "", [], ""]
        continue
    if cur is not None:
        m = re.match(r"script:\s*(.+)", s)
        if m:
            cur[1] = m.group(1).strip().strip('"').strip("'")
            continue
        m = re.match(r"args:\s*\[(.*)\]", s)
        if m:
            inner = m.group(1).strip()
            if inner:
                cur[2] = [a.strip().strip('"').strip("'") for a in inner.split(",")]
            continue
        m = re.match(r"artifacts:\s*\[(.*)\]", s)
        if m:
            inner = m.group(1).strip()
            if inner:
                first = inner.split(",")[0].strip().strip('"').strip("'")
                # 只取文件名, 写入当日 $OUT（spec 内日期段仅历史锚）
                parts = first.replace("\\", "/").split("/")
                cur[3] = parts[-1]
            continue
flush()
for c in cases:
    print("\t".join(c))
PYEOF

if [ ! -s "$OUT/.cases.tsv" ]; then
  echo "TASK-RUN FAIL pkg=$PKG date=$TODAY no_cases_parsed"
  exit 1
fi

# ---- 逐案执行
pass_n=0; fail_n=0; pend_n=0
fail_lines=""
while IFS= read -r line; do
  line=${line%$'\r'}          # Python stdout 在 Windows 转 \r\n, 剥除
  [ -z "$line" ] && continue
  IFS=$'\t' read -r -a f <<< "$line"
  env="${f[0]}"; case_id="${f[1]}"; script="${f[2]:-}"
  artfile="${f[${#f[@]}-1]}"
  args=()
  if [ "${#f[@]}" -gt 4 ]; then
    for ((i=3; i<${#f[@]}-1; i++)); do args+=("${f[$i]}"); done
  fi
  base="${env}-${case_id}"
  art_rel="${artfile:-${base}.json}"
  if [ "$script" = "-" ] || [ -z "$script" ]; then
    status="PENDING"; rc=""; dur=0; note="spec placeholder (script=-)"
  else
    start=$(date +%s)
    timeout 900 bash "$script" ${args[@]+"${args[@]}"} > "$OUT/${base}.log" 2>&1
    rc=$?
    end=$(date +%s); dur=$((end-start))
    if [ "$rc" -eq 0 ]; then status="PASS"; else status="FAIL"; fi
    note=""
  fi
  if ! python3 - "$OUT/${art_rel}" "$env" "$case_id" "$status" "$rc" "$dur" "$note" "$TS_ISO" <<'PYEOF'
import sys, json
path, env, cid, status, rc, dur, note, ts = sys.argv[1:9]
obj = {"case": cid, "env": env, "status": status,
       "rc": int(rc) if rc not in ("", None) else None,
       "duration_s": int(dur), "ts": ts, "note": note}
with open(path, "w", encoding="utf-8") as f:
    json.dump(obj, f, ensure_ascii=False, indent=1)
PYEOF
  then
    echo "TASK-RUN FAIL pkg=$PKG date=$TODAY json_write_failed=${art_rel}"
    exit 1
  fi
  case "$status" in
    PASS) pass_n=$((pass_n+1));;
    FAIL) fail_n=$((fail_n+1)); fail_lines="${fail_lines}${base} rc=${rc} (${dur}s)
";;
    PENDING) pend_n=$((pend_n+1));;
  esac
done < "$OUT/.cases.tsv"

total=$((pass_n+fail_n+pend_n))
python3 - "$OUT/SUMMARY.json" "$PKG" "$TODAY" "$total" "$pass_n" "$fail_n" "$pend_n" "$TS_ISO" <<'PYEOF'
import sys, json
path, pkg, date, total, p, f, pe, ts = sys.argv[1:9]
json.dump({"pkg": pkg, "date": date, "total": int(total), "pass": int(p),
           "fail": int(f), "pending": int(pe), "ts": ts},
          open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
PYEOF
rm -f "$OUT/.cases.tsv"

if [ "$fail_n" -gt 0 ]; then
  echo "TASK-RUN FAIL pkg=$PKG date=$TODAY total=$total pass=$pass_n fail=$fail_n pending=$pend_n"
  printf '%s' "$fail_lines"
  exit 1
fi
exit 0
