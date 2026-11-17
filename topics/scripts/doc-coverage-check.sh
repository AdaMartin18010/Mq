#!/usr/bin/env bash
# 文档覆盖检查
# 用途：对比 test-registry.tsv 中 doc_refs 声明的文档族与 topics/01~04 系列实际文档，
#       输出未覆盖族清单与覆盖率。
# 用法：doc-coverage-check.sh [--registry 路径] [--verbose] [--strict]
#   --registry 路径   指定注册表文件（默认同目录 test-registry.tsv）
#   --verbose         列出每篇实际文档的覆盖状态
#   --strict          存在未覆盖文档族时退出码 1
# 退出码：0=正常；1=--strict 且存在未覆盖（或参数异常）；2=注册表不存在
# 依赖：bash 4+、awk、find
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REGISTRY="$SCRIPT_DIR/test-registry.tsv"
VERBOSE=0
STRICT=0

usage() {
  cat <<'EOF'
用法: doc-coverage-check.sh [--registry 路径] [--verbose] [--strict]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --registry)
      REGISTRY="${2:-}"; shift 2 ;;
    --verbose)
      VERBOSE=1; shift ;;
    --strict)
      STRICT=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "[ERROR] 未知参数: $1"; usage; exit 1 ;;
  esac
done

if [[ ! -f "$REGISTRY" ]]; then
  echo "[ERROR] 注册表不存在: $REGISTRY"
  exit 2
fi

# 收集 01~04 系列实际文档编号，格式：series-num
mapfile -t ACTUAL_FILES < <(find "$PROJECT_ROOT/topics" -type f -name '0[1-4]-*.md' ! -name 'README.md' | sort)

declare -A ACTUAL_SET
actual_count=0
for f in "${ACTUAL_FILES[@]}"; do
  base="$(basename "$f" .md)"
  if [[ "$base" =~ ^(0[1-4])-([0-9]+)- ]]; then
    key="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}"
    ACTUAL_SET["$key"]=1
    actual_count=$((actual_count + 1))
  fi
done

# 判断单个 doc_refs token 是否被实际文档覆盖
# token 支持 0X-NN 或 0X-NN~MM，也支持非编号目录/文件标记
check_token_covered() {
  local tok="$1"
  if [[ "$tok" =~ ^(0[1-4])-([0-9]+)(~([0-9]+))?$ ]]; then
    local s="${BASH_REMATCH[1]}"
    local n1="${BASH_REMATCH[2]}"
    local n2="${BASH_REMATCH[4]:-$n1}"
    local n key_n
    for ((n=10#$n1; n<=10#$n2; n++)); do
      printf -v key_n '%02d' "$n"
      if [[ -n "${ACTUAL_SET[${s}-${key_n}]+x}" ]]; then
        return 0
      fi
    done
    return 1
  fi

  # 非编号 token：AI_Skill / examples / AGENTS.md / INDEX.md / TEST-XX 等
  local probe
  for probe in "$PROJECT_ROOT/topics/$tok" "$PROJECT_ROOT/topics/Testing/$tok.md" "$PROJECT_ROOT/$tok" "$PROJECT_ROOT/$tok.md"; do
    [[ -e "$probe" ]] && return 0
  done
  return 1
}

# 从注册表读取 doc_refs 作为文档族，去重
declare -A FAMILY_COV
declare -a FAMILIES

while IFS=$'\t' read -r -a cols; do
  [[ ${#cols[@]} -lt 6 ]] && continue
  local_id="${cols[0]}"
  [[ "$local_id" == "id" || -z "$local_id" || "$local_id" =~ ^# ]] && continue

  fam="${cols[4]}"
  [[ -z "$fam" ]] && continue
  row_status="${cols[5]:-}"

  if [[ -z "${FAMILY_COV[$fam]+x}" ]]; then
    FAMILIES+=("$fam")
    FAMILY_COV[$fam]=0
  fi

  # pending（待补缺口）行不纳入覆盖统计：族被登记为已知，但保持未覆盖状态
  [[ "$row_status" == "pending" ]] && continue

  IFS=',' read -r -a tokens <<< "$fam"
  for tok in "${tokens[@]}"; do
    tok="$(echo "$tok" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if check_token_covered "$tok"; then
      FAMILY_COV[$fam]=1
      break
    fi
  done
done < "$REGISTRY"

# 按首 token 的系列分组统计
declare -A SERIES_TOTAL
declare -A SERIES_UNCOVERED
total_family=${#FAMILIES[@]}
covered_family=0

for fam in "${FAMILIES[@]}"; do
  first_tok="$(echo "$fam" | cut -d, -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  series="other"
  if [[ "$first_tok" =~ ^(0[1-4])- ]]; then
    series="${BASH_REMATCH[1]}"
  fi

  SERIES_TOTAL[$series]=$(( ${SERIES_TOTAL[$series]:-0} + 1 ))
  if [[ ${FAMILY_COV[$fam]} -eq 1 ]]; then
    covered_family=$((covered_family + 1))
  else
    SERIES_UNCOVERED[$series]=$(( ${SERIES_UNCOVERED[$series]:-0} + 1 ))
  fi
done

echo "=== 文档覆盖检查 ==="
echo "[INFO] 注册表: $REGISTRY"
echo "[INFO] 01~04 系列实际文档: $actual_count 篇"
echo "[INFO] 文档族总数: $total_family"
echo "[INFO] 已覆盖族数: $covered_family"

# --verbose：列出每篇实际文档是否被任一族覆盖
if [[ $VERBOSE -eq 1 ]]; then
  echo ""
  echo "--- 各文档覆盖状态 ---"
  for f in "${ACTUAL_FILES[@]}"; do
    base="$(basename "$f" .md)"
    matched=0
    [[ "$base" =~ ^(0[1-4])-([0-9]+)- ]] || continue
    doc_key="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}"
    for fam in "${FAMILIES[@]}"; do
      IFS=',' read -r -a tokens <<< "$fam"
      for tok in "${tokens[@]}"; do
        tok="$(echo "$tok" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        if [[ "$tok" =~ ^(0[1-4])-([0-9]+)(~([0-9]+))?$ ]]; then
          s="${BASH_REMATCH[1]}"
          n1="${BASH_REMATCH[2]}"
          n2="${BASH_REMATCH[4]:-$n1}"
          for ((n=10#$n1; n<=10#$n2; n++)); do
            printf -v key_n '%02d' "$n"
            if [[ "${s}-${key_n}" == "$doc_key" ]]; then
              matched=1
              break 3
            fi
          done
        fi
      done
    done
    if [[ $matched -eq 1 ]]; then
      echo "[OK]   $base"
    else
      echo "[WARN] $base 未注册"
    fi
  done
fi

# 未覆盖族清单
echo ""
echo "--- 未覆盖文档族清单 ---"
any_uncovered=0
for series in 01 02 03 04 other; do
  t=${SERIES_TOTAL[$series]:-0}
  u=${SERIES_UNCOVERED[$series]:-0}
  [[ $t -eq 0 ]] && continue
  echo "[INFO] $series 系列: 未覆盖 $u / 总族 $t"
  if [[ $u -gt 0 ]]; then
    any_uncovered=1
    for fam in "${FAMILIES[@]}"; do
      first_tok="$(echo "$fam" | cut -d, -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      s2="other"
      [[ "$first_tok" =~ ^(0[1-4])- ]] && s2="${BASH_REMATCH[1]}"
      [[ "$s2" == "$series" && ${FAMILY_COV[$fam]} -eq 0 ]] && echo "[WARN]   $fam"
    done
  fi
done

pct=$(awk -v c="$covered_family" -v t="$total_family" 'BEGIN{ if(t==0){print "0.0"} else {printf "%.1f", c*100/t} }')

echo ""
if [[ $any_uncovered -eq 1 && $STRICT -eq 1 ]]; then
  echo "[FAIL] 文档族覆盖: $covered_family/$total_family ($pct%)"
  exit 1
else
  echo "[INFO] 文档族覆盖: $covered_family/$total_family ($pct%)"
  exit 0
fi
