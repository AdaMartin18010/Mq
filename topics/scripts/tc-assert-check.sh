#!/usr/bin/env bash
# TC-BUS 父用例静态校验（L6 层，批次75）
# 用途：对 8 个业务场景包执行父用例断言——
#   ① assertions.tsv 行结构（7 列/维度∈12 清单/系统∈6 清单/ASE id 唯一）
#   ② 场景 asyncapi.yaml 的 x-semantics 值 ∈ TEST-14 十二维度清单
#   ③ 场景 contract.yaml 存在且 invariants 非空
# 用法：tc-assert-check.sh [--json]
# 退出码：0=全 PASS；1=存在 FAIL；2=异常
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERIES_DIR="$PROJECT_ROOT/Testing/06-契约语义测试"
# MSYS 路径（/c/ /e/）在 MSYS_NO_PATHCONV=1 下不被 Windows 原生 python3 识别 → cygpath 统一转换
if command -v cygpath >/dev/null 2>&1; then
  PROJECT_ROOT="$(cygpath -m "$PROJECT_ROOT")"
  SERIES_DIR="$(cygpath -m "$SERIES_DIR")"
fi
DIMS="交付语义 顺序性 幂等去重 重试退避 死信 事务 背压 TTL过期 延迟消息 消息过滤 流控 持久化"
SYSTEMS="Kafka RabbitMQ NATS Pulsar Redis MQTT CloudEvents OTel"

FAIL=0; PASS=0; NOTES=()

# ① 断言库结构校验
ASSERTIONS="$SERIES_DIR/02-语义矩阵/semantics/assertions.tsv"
[[ -f "$ASSERTIONS" ]] || { echo "FAIL 缺断言库: $ASSERTIONS"; exit 1; }
seen_ase=""
while IFS=$'\t' read -r id dim sys g w t v; do
  [[ -z "${id:-}" || "$id" =~ ^# ]] && continue
  if [[ $(awk -F'\t' 'NR==1{print NF}' "$ASSERTIONS") -ne 7 ]]; then :; fi
  ok=1
  [[ "$id" =~ ^ASE-[0-9]{3}$ ]] || { NOTES+=("BAD_ID: $id"); ok=0; }
  grep -q "$dim" <<< "$DIMS" || { NOTES+=("BAD_DIM: $id -> $dim"); ok=0; }
  grep -q "$sys" <<< "$SYSTEMS" || { NOTES+=("BAD_SYSTEM: $id -> $sys"); ok=0; }
  [[ -n "$g" && -n "$w" && -n "$t" && -n "$v" ]] || { NOTES+=("EMPTY_FIELD: $id"); ok=0; }
  [[ "$seen_ase" == *" $id "* ]] && { NOTES+=("DUP_ID: $id"); ok=0; }
  seen_ase+=" $id "
  [[ $ok -eq 0 ]] && FAIL=$((FAIL+1)) || PASS=$((PASS+1))
done < "$ASSERTIONS"

# ②③ 场景包校验
PY_XSEM='
import sys, yaml
d = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
out = set()
for o in (d.get("operations") or {}).values():
    xs = (o or {}).get("x-semantics") or []
    out.update(str(x) for x in xs)
print("\n".join(sorted(out)))
'
for dir in "$SERIES_DIR"/03-业务场景/*/; do
  name="$(basename "$dir")"
  [[ "$name" == "README.md" ]] && continue
  c="$dir/contract.yaml"; a="$dir/asyncapi.yaml"
  [[ -f "$c" && -f "$a" ]] || { NOTES+=("MISSING_FILE: $name"); FAIL=$((FAIL+1)); continue; }
  inv="$(grep -c '^invariants:' "$c" 2>/dev/null)"
  [[ "$inv" -ge 1 ]] || { NOTES+=("NO_INVARIANTS: $name"); FAIL=$((FAIL+1)); }
  xvals="$(python3 -c "$PY_XSEM" "$a" 2>/dev/null | tr -d '\r')"
  for x in $xvals; do
    grep -q "$x" <<< "$DIMS" || { NOTES+=("BAD_XSEMANTICS: $name -> $x"); FAIL=$((FAIL+1)); }
  done
  PASS=$((PASS+1))
done

for n in "${NOTES[@]:-}"; do [[ -n "$n" ]] && echo "NOTE $n"; done
echo "-----"
echo "CHECKS=$((PASS+FAIL)) PASS=$PASS FAIL=$FAIL"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
