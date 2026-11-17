#!/usr/bin/env bash
# 契约 spec 静态校验器（Testing 06 子系列 L1-L2 层，批次71）
# 用途：校验六系统 AsyncAPI spec 的结构合法性，实现 spectral-asyncapi-ruleset.yaml 核心规则
# 用法：contract-spec-check.sh [--json] [--dir 路径]
#   默认校验：契约语义测试/01-契约规格/specs/*.yaml
#             + topics/config-templates/asyncapi-kafka-example.yaml
#             + topics/config-templates/asyncapi-mqtt-example.yaml
# 退出码：0=全 PASS；1=存在 FAIL；2=参数/解析异常
# 依赖：bash 4+、python3（不可用则退化为结构 grep 并标注 DEGRADED）
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERIES_DIR="$PROJECT_ROOT/契约语义测试"
JSON_OUT=0

usage() { echo "用法: contract-spec-check.sh [--json] [--dir 路径]"; exit 2; }
[[ "${1:-}" == "--help" ]] && usage
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_OUT=1; shift ;;
    --dir) SERIES_DIR="$2"; shift 2 ;;
    *) usage ;;
  esac
done

SPECS=()
for f in "$SERIES_DIR"/01-契约规格/specs/*.yaml; do [[ -f "$f" ]] && SPECS+=("$f"); done
SPECS+=("$PROJECT_ROOT/topics/config-templates/asyncapi-kafka-example.yaml")
SPECS+=("$PROJECT_ROOT/topics/config-templates/asyncapi-mqtt-example.yaml")
[[ ${#SPECS[@]} -eq 0 ]] && { echo "ERROR: 未找到任何 spec"; exit 2; }

# YAML 结构校验（python3 实现；不可用则 DEGRADED）
PY_CHECK='
import sys, yaml
f = sys.argv[1]
try:
    d = yaml.safe_load(open(f, encoding="utf-8"))
except Exception as e:
    print(f"YAML_PARSE_FAIL: {e}"); sys.exit(1)
errs = []
if not isinstance(d, dict): print("YAML_PARSE_FAIL: 非映射根"); sys.exit(1)
ver = str(d.get("asyncapi", ""))
if not ver.startswith("3."): errs.append(f"ASYNCAPI_VERSION: {ver or 缺失}（要求 3.x）")
info = d.get("info") or {}
if not info.get("title"): errs.append("INFO_TITLE_MISSING")
if not info.get("version"): errs.append("INFO_VERSION_MISSING")
chs = d.get("channels") or {}
if not chs: errs.append("CHANNELS_EMPTY")
ops = d.get("operations") or {}
for oid, o in ops.items():
    ref = ((o or {}).get("channel") or {}).get("$ref", "")
    if ref and ref.startswith("#/channels/"):
        name = ref[len("#/channels/"):]
        if name not in chs: errs.append(f"OP_REF_DANGLING: {oid}->{name}")
msgs = ((d.get("components") or {}).get("messages")) or {}
for cid, c in chs.items():
    for mname, m in ((c or {}).get("messages") or {}).items():
        ref = (m or {}).get("$ref", "") if isinstance(m, dict) else ""
        if ref.startswith("#/components/messages/") and ref.split("/")[-1] not in msgs:
            errs.append(f"MSG_REF_DANGLING: {cid}->{mname}")
    for m in msgs.values():
        p = ((m or {}).get("payload") or {}).get("$ref", "")
        if p.startswith("#/components/schemas/"):
            sch = ((d.get("components") or {}).get("schemas") or {})
            if p.split("/")[-1] not in sch: errs.append(f"SCHEMA_REF_DANGLING: {p}")
    b = (c or {}).get("bindings") or {}
    known = {"kafka","mqtt","amqp","amqp1","nats","pulsar","redis","http","ws","jms","sns","sqs","stomp","googlepubsub","ibmmq","solace","anypointmq","mqtt5","ros2"}
    for k in b:
        if k not in known: errs.append(f"BINDING_UNKNOWN: {k}（未在 asyncapi/bindings 索引，需确认或 x- 前缀）")
    pb = (b.get("pulsar") or {})
    if pb and ("namespace" not in pb or "persistence" not in pb):
        errs.append("PULSAR_BINDING_REQUIRED: namespace/persistence 必填（v0.1.0）")
print("OK" if not errs else "FAIL: " + "; ".join(errs))
'

PASS=0; FAIL=0; RESULTS=()
for spec in "${SPECS[@]}"; do
  name="$(basename "$spec")"
  if command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
    PY=python3; command -v python3 >/dev/null 2>&1 || PY=python
    out="$("$PY" -c "$PY_CHECK" "$spec" 2>&1)"; rc=$?
  else
    out="DEGRADED: python3 缺失，仅做 grep 结构检查"
    grep -q "^asyncapi: '3\." "$spec" && grep -q "^info:" "$spec" && rc=0 || rc=1
  fi
  if [[ $rc -eq 0 && "$out" == "OK" ]]; then
    PASS=$((PASS+1)); RESULTS+=("PASS $name")
  else
    FAIL=$((FAIL+1)); RESULTS+=("FAIL $name :: $out")
  fi
  # x- 扩展清点（01-44 治理登记输入）
  exts="$(grep -oE '^[[:space:]]+x-[a-z0-9-]+' "$spec" 2>/dev/null | tr -d ' ' | sort -u | tr '\n' ' ')"
  [[ -n "$exts" ]] && RESULTS+=("  X-EXT $name: $exts")
done

for r in "${RESULTS[@]}"; do echo "$r"; done
echo "-----"
echo "SPECS=${#SPECS[@]} PASS=$PASS FAIL=$FAIL"
if [[ $JSON_OUT -eq 1 ]]; then
  printf '{"total":%d,"pass":%d,"fail":%d}\n' "${#SPECS[@]}" "$PASS" "$FAIL"
fi
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
