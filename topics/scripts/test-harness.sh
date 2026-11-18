#!/usr/bin/env bash
# 统一用例执行框架
# 用途：读取 test-registry.tsv，按环境/域/ID 过滤并顺序执行用例脚本，
#       记录每用例日志与汇总报告。
# 用法：test-harness.sh [选项]
#   --env E0|E1|E2|E3        按环境过滤（支持逗号组合中的任意一项）
#   --domain DEP|INT|CLU|OBS|SEC|CON|CHK  按域过滤
#   --id TC-DEP-01|CHK-001   按用例ID精确匹配
#   --dry-run                只打印将执行的清单
#   --registry 路径           指定注册表文件（默认同目录 test-registry.tsv）
#   --out 路径                结果目录（默认项目根下 results/）
#   --timeout 秒              单脚本超时（默认 300）
# 退出码：0=全 PASS/SKIP；1=存在 FAIL；2=参数/注册表异常
# 依赖：bash 4+、awk、timeout（coreutils）、GNU date
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

REGISTRY="$SCRIPT_DIR/test-registry.tsv"
OUT_DIR="$PROJECT_ROOT/results"
ENV_FILTER=""
DOMAIN_FILTER=""
ID_FILTER=""
SYS_FILTER=""     # 批次119：集成矩阵系统过滤（匹配 TC-<SYS>- 前缀）
LANG_FILTER=""    # 批次119：语言过滤（匹配 -<LANG>- 段）
DRY_RUN=0
TIMEOUT_SEC=300

usage() {
  cat <<'EOF'
用法: test-harness.sh [选项]
  --env E0|E1|E2|E3        按环境过滤
  --domain DEP|INT|CLU|OBS|SEC|CON|CHK  按域过滤
  --id ID                  按用例ID精确匹配
  --dry-run                只打印将执行的清单
  --registry 路径           指定注册表文件
  --out 路径                结果输出目录
  --timeout 秒              单脚本超时（默认 300）
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_FILTER="${2:-}"; shift 2 ;;
    --domain)
      DOMAIN_FILTER="${2:-}"; shift 2 ;;
    --id)
      ID_FILTER="${2:-}"; shift 2 ;;
    --sys) SYS_FILTER="${2:-}"; shift 2 ;;
    --lang) LANG_FILTER="${2:-}"; shift 2 ;;
    --dry-run)
      DRY_RUN=1; shift ;;
    --registry)
      REGISTRY="${2:-}"; shift 2 ;;
    --out)
      OUT_DIR="${2:-}"; shift 2 ;;
    --timeout)
      TIMEOUT_SEC="${2:-300}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "[ERROR] 未知参数: $1"; usage; exit 2 ;;
  esac
done

if [[ ! -f "$REGISTRY" ]]; then
  echo "[ERROR] 注册表不存在: $REGISTRY"
  exit 2
fi

TS="$(date +%Y%m%d-%H%M%S)"
ENV_LABEL="${ENV_FILTER:-all}"
SUMMARY="$OUT_DIR/summary-${ENV_LABEL}-${TS}.md"

# 过滤函数
row_matches() {
  local id="$1" domain="$2" envs="$3"
  if [[ -n "$DOMAIN_FILTER" && "$domain" != "$DOMAIN_FILTER" ]]; then
    return 1
  fi
  if [[ -n "$ID_FILTER" && "$id" != "$ID_FILTER" ]]; then
    return 1
  fi
  if [[ -n "$SYS_FILTER" && "$id" != TC-"$SYS_FILTER"-* ]]; then
    return 1
  fi
  if [[ -n "$LANG_FILTER" && "$id" != *-"$LANG_FILTER"-* ]]; then
    return 1
  fi
  if [[ -n "$ENV_FILTER" ]]; then
    if [[ ",${envs}," != *",${ENV_FILTER},"* ]]; then
      return 1
    fi
  fi
  return 0
}

# 记录单次脚本结果到日志
run_one_script() {
  local id="$1" script="$2" log="$3"
  local script_path="$SCRIPT_DIR/$script"
  local rc

  {
    echo "===== $id / $script 开始 $(date '+%F %T') ====="
    if [[ ! -f "$script_path" ]]; then
      echo "[FAIL] 脚本缺失: $script_path"
      echo "===== 结束 rc=FAIL(缺失) ====="
      return 1
    fi
    if [[ ! -x "$script_path" ]]; then
      echo "[FAIL] 脚本不可执行: $script_path"
      echo "===== 结束 rc=FAIL(不可执行) ====="
      return 1
    fi

    timeout --signal=TERM --kill-after=10 "$TIMEOUT_SEC" "$script_path"
    rc=$?

    case "$rc" in
      0)  echo "===== 结束 rc=PASS =====" ;;
      1)  echo "===== 结束 rc=FAIL =====" ;;
      2)  echo "===== 结束 rc=SKIP =====" ;;
      124) echo "===== 结束 rc=FAIL(timeout) =====" ;;
      *)  echo "===== 结束 rc=FAIL(unknown:$rc) =====" ;;
    esac
    return "$rc"
  } >>"$log" 2>&1
}

# 解析退出码为状态字符串
rc_to_status() {
  local rc="$1"
  case "$rc" in
    0) echo "PASS" ;;
    1) echo "FAIL" ;;
    2) echo "SKIP" ;;
    124) echo "FAIL(timeout)" ;;
    *) echo "FAIL(unknown:$rc)" ;;
  esac
}

declare -a IDS=()
declare -a DOMAINS=()
declare -a SCRIPTS=()
declare -a STATUSES=()
declare -a DETAILS=()

pass_count=0
fail_count=0
skip_count=0
selected_count=0

if [[ "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$OUT_DIR"
fi

# 主循环：逐行读取注册表
while IFS=$'\t' read -r -a cols; do
    # 跳过注释/空行/表头
    [[ ${#cols[@]} -lt 6 ]] && continue
    local_id="${cols[0]}"
    [[ "$local_id" == "id" || -z "$local_id" || "$local_id" =~ ^# ]] && continue

    local_domain="${cols[1]}"
    local_scripts="${cols[2]}"
    local_env="${cols[3]}"

    if ! row_matches "$local_id" "$local_domain" "$local_env"; then
      continue
    fi

    selected_count=$((selected_count + 1))

    if [[ "$DRY_RUN" -eq 1 ]]; then
      printf '[DRY] %s\tdomain=%s\tenv=%s\tscripts=%s\n' "$local_id" "$local_domain" "$local_env" "$local_scripts"
      continue
    fi

    log_file="$OUT_DIR/${local_id}.log"
    : >"$log_file"

    if [[ "$local_scripts" == "-" || -z "$local_scripts" ]]; then
      echo "[SKIP] $local_id: 无对应脚本" | tee -a "$log_file"
      IDS+=("$local_id")
      DOMAINS+=("$local_domain")
      SCRIPTS+=("-")
      STATUSES+=("SKIP")
      DETAILS+=("无脚本")
      skip_count=$((skip_count + 1))
      continue
    fi

    overall_status="PASS"
    detail_parts=()

    IFS=',' read -r -a script_arr <<< "$local_scripts"
    for s in "${script_arr[@]}"; do
      s="$(echo "$s" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      run_one_script "$local_id" "$s" "$log_file"
      rc=$?
      status_str="$(rc_to_status "$rc")"
      detail_parts+=("$s:$status_str")
      # 优先级：FAIL > SKIP > PASS
      if [[ "$status_str" == FAIL* ]]; then
        overall_status="$status_str"
      elif [[ "$status_str" == SKIP* && "$overall_status" == "PASS" ]]; then
        overall_status="SKIP"
      fi
      echo "[$(date '+%T')] $local_id / $s => $status_str" | tee -a "$log_file"
    done

    case "$overall_status" in
      PASS)  pass_count=$((pass_count + 1)) ;;
      SKIP)  skip_count=$((skip_count + 1)) ;;
      *)     fail_count=$((fail_count + 1)) ;;
    esac

    IDS+=("$local_id")
    DOMAINS+=("$local_domain")
    SCRIPTS+=("$local_scripts")
    STATUSES+=("$overall_status")
    DETAILS+=("$(IFS=';'; echo "${detail_parts[*]}")")

    echo "[INFO] $local_id => $overall_status"
done < "$REGISTRY"

# 输出汇总报告（dry-run 不生成文件）
if [[ "$DRY_RUN" -eq 0 ]]; then
{
  echo "# 测试执行汇总"
  echo ""
  echo "- 注册表: $REGISTRY"
  echo "- 过滤条件: env=${ENV_FILTER:-无}, domain=${DOMAIN_FILTER:-无}, id=${ID_FILTER:-无}"
  echo "- 执行时间: $TS"
  echo "- 选中用例数: $selected_count"
  echo "- PASS: $pass_count / FAIL: $fail_count / SKIP: $skip_count"
  echo ""
  echo "| ID | 域 | 脚本 | 结果 | 明细 |"
  echo "|----|----|------|------|------|"
  for i in "${!IDS[@]}"; do
    echo "| ${IDS[$i]} | ${DOMAINS[$i]} | ${SCRIPTS[$i]} | ${STATUSES[$i]} | ${DETAILS[$i]} |"
  done
  echo ""
  if [[ $fail_count -gt 0 ]]; then
    echo "## 失败清单"
    for i in "${!IDS[@]}"; do
      if [[ "${STATUSES[$i]}" != PASS* && "${STATUSES[$i]}" != SKIP* ]]; then
        echo "- ${IDS[$i]}: ${STATUSES[$i]} (${DETAILS[$i]})"
      fi
    done
  fi
} > "$SUMMARY"
fi

# stdout 统计
echo ""
echo "=== 测试执行统计 ==="
echo "选中用例: $selected_count"
echo "PASS: $pass_count"
echo "FAIL: $fail_count"
echo "SKIP: $skip_count"
echo "汇总报告: $SUMMARY"

if [[ "$DRY_RUN" -eq 1 ]]; then
  exit 0
fi

if [[ $fail_count -gt 0 ]]; then
  echo "[FAIL] 存在失败用例，退出码 1"
  exit 1
else
  echo "[PASS] 全绿或全部 SKIP，退出码 0"
  exit 0
fi
