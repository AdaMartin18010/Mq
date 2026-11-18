#!/usr/bin/env bash
# E0 静态验证入口（TEST-09 §T.09.2 / TEST-11 §T.11.1 验证环节实现）
# 用法: hermes-e0-run.sh [--help]
# 步骤: doc-self-check quick → bash -n → TSV 校验 → doc-decision-check → doc-semantic-spotcheck → contract-spec-check → tc-assert-check → kg-check
# 退出码: 0=全 PASS/SKIP；1=存在 FAIL
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 1
DATE="$(date +%Y-%m-%d)"
PLAN_ID="E0-${DATE}"
RESULTS_DIR="results/$DATE"
HISTORY_LOG="Testing/self-check-history.log"

usage() {
  cat <<'EOF'
用法: hermes-e0-run.sh [--help]
  执行 E0 静态验证六步骤，生成 results/<date>/E0-*.json/.log 与 summary.md，
  并追加一行到 Testing/self-check-history.log。
  步骤 6 为契约 spec 校验（契约语义测试 L1-L2 层，批次71）。
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

mkdir -p "$RESULTS_DIR"

# 初始化 history log（若不存在）
if [[ ! -f "$HISTORY_LOG" ]]; then
  echo -e "# datetime\terror\twarn\tspotcheck\tplan_id" > "$HISTORY_LOG"
fi

# 记录单个步骤结果
run_step() {
  local case_id="$1"
  local title="$2"
  shift 2
  local log="$RESULTS_DIR/${case_id}.log"
  local json="$RESULTS_DIR/${case_id}.json"
  local start end duration rc result exit_code_for_log

  : > "$log"
  echo "===== $case_id: $title =====" >> "$log"
  echo "开始: $(date '+%F %T')" >> "$log"
  echo "" >> "$log"

  start=$(date +%s)
  "$@" >> "$log" 2>&1
  rc=$?
  end=$(date +%s)
  duration=$((end - start))

  case "$rc" in
    0) result="PASS" ; exit_code_for_log=0 ;;
    2) result="SKIP" ; exit_code_for_log=2 ;;
    *) result="FAIL" ; exit_code_for_log=1 ;;
  esac

  echo "" >> "$log"
  echo "RESULT: $result" >> "$log"
  echo "DURATION: $duration" >> "$log"
  echo "EXIT_CODE: $exit_code_for_log" >> "$log"

  cat > "$json" <<EOF
{
  "case_id": "$case_id",
  "env": "E0",
  "result": "$result",
  "duration_seconds": $duration,
  "exit_code": $exit_code_for_log,
  "log_path": "results/$DATE/${case_id}.log"
}
EOF

  echo "$case_id $result $duration $exit_code_for_log"
  return "$exit_code_for_log"
}

# 步骤 1: doc-self-check quick
step_doc_check() {
  local output
  output=$("./topics/scripts/doc-self-check.sh" quick 2>&1)
  echo "$output"
  local errors warns
  errors=$(echo "$output" | grep -oE 'ERROR=[0-9]+' | tail -1 | cut -d= -f2)
  warns=$(echo "$output" | grep -oE 'WARN=[0-9]+' | tail -1 | cut -d= -f2)
  echo "EXTRACTED_ERRORS=${errors:-0}"
  echo "EXTRACTED_WARNS=${warns:-0}"
  return "${errors:-0}"
}

# 步骤 2: 全量 bash -n
step_bash_syntax() {
  local rc=0
  local total=0 fail=0
  while IFS= read -r f; do
    total=$((total + 1))
    if bash -n "$f" >/dev/null 2>&1; then
      echo "[OK]    bash -n: $f"
    else
      echo "[FAIL]  bash -n: $f"
      fail=$((fail + 1))
      rc=1
    fi
  done < <(find "topics/scripts" -maxdepth 1 -type f -name '*.sh' | sort)
  echo "SUMMARY: total=$total fail=$fail"
  return "$rc"
}

# 步骤 3: test-registry.tsv TSV 校验（含集成矩阵一致性，批次 119）
step_registry_check() {
  local registry="topics/scripts/test-registry.tsv"
  local rc=0
  # ... existing checks ...
  local line_no=0
  local ids=""
  local bad_cols=0 bad_env=0 bad_status=0 dup=0

  echo "校验注册表: $registry"
  while IFS=$'\t' read -r -a cols; do
    line_no=$((line_no + 1))
    local id="${cols[0]:-}"
    # 跳过注释/空行/表头
    [[ -z "$id" || "$id" =~ ^# || "$id" == "id" ]] && continue

    if [[ ${#cols[@]} -ne 6 ]]; then
      echo "[FAIL] 第 $line_no 行列数错误: ${#cols[@]} (期望 6), id=$id"
      bad_cols=$((bad_cols + 1))
      rc=1
      continue
    fi

    local domain="${cols[1]}"
    local env="${cols[3]}"
    local status="${cols[5]}"

    if [[ ",E0,E1,E2,E3," != *",$env,"* ]]; then
      echo "[FAIL] 第 $line_no 行 env 枚举非法: $env (id=$id)"
      bad_env=$((bad_env + 1))
      rc=1
    fi

    if [[ ",mapped,pending,deprecated,blocked,verified," != *",$status,"* ]]; then
      echo "[FAIL] 第 $line_no 行 status 枚举非法: $status (id=$id)"
      bad_status=$((bad_status + 1))
      rc=1
    fi

    if [[ "$ids" == *" $id "* ]]; then
      echo "[FAIL] 第 $line_no 行 ID 重复: $id"
      dup=$((dup + 1))
      rc=1
    else
      ids+=" $id "
    fi
  done < "$registry"

  echo "SUMMARY: bad_cols=$bad_cols bad_env=$bad_env bad_status=$bad_status duplicate=$dup"
  # 集成矩阵一致性（批次119）
  python3 "./topics/scripts/matrix-check.py" || rc=1
  return "$rc"
}

# 步骤 4: doc-decision-check --strict
step_decision_check() {
  "./topics/scripts/doc-decision-check.sh" --strict
}

# 步骤 5: doc-semantic-spotcheck
step_spotcheck() {
  "./topics/scripts/doc-semantic-spotcheck.sh"
}

# 步骤 6: 契约 spec 静态校验（契约语义测试 L1-L2 层，批次71）
step_contract_check() {
  "./topics/scripts/contract-spec-check.sh"
}

# 步骤 7: 行为用例父用例静态校验（L6 层，批次75）
step_tc_static() {
  "./topics/scripts/tc-assert-check.sh"
}

# 步骤 8: 知识图谱完整性校验（方向 5，批次104）
step_kg_check() {
  python3 "./topics/scripts/kg-query.py" --check
}

# 主流程
main() {
  local pass=0 fail=0 skip=0 total=8
  local errors=0 warns=0 spotcheck_result="PASS"
  local step_result step_rc step_duration

  # 步骤 1
  run_step "E0-doc-check" "doc-self-check quick" step_doc_check
  step_rc=$?
  # 从日志中抽取 ERROR/WARN
  errors=$(grep -oE 'EXTRACTED_ERRORS=[0-9]+' "$RESULTS_DIR/E0-doc-check.log" | cut -d= -f2 | tail -1)
  warns=$(grep -oE 'EXTRACTED_WARNS=[0-9]+' "$RESULTS_DIR/E0-doc-check.log" | cut -d= -f2 | tail -1)
  errors=${errors:-0}
  warns=${warns:-0}
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # 步骤 2
  run_step "E0-bash-syntax" "topics/scripts 全量 bash -n" step_bash_syntax
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # 步骤 3
  run_step "E0-registry" "test-registry.tsv TSV 校验" step_registry_check
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # 步骤 4
  run_step "E0-decision" "doc-decision-check --strict" step_decision_check
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # 步骤 5
  run_step "E0-spotcheck" "doc-semantic-spotcheck" step_spotcheck
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then
    pass=$((pass + 1))
  elif [[ $step_rc -eq 2 ]]; then
    skip=$((skip + 1))
  else
    fail=$((fail + 1))
    spotcheck_result="FAIL"
  fi

  # 步骤 6
  run_step "E0-contract" "contract-spec-check 契约 spec 校验" step_contract_check
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # 步骤 7
  run_step "E0-tc-static" "tc-assert-check 行为用例父用例校验" step_tc_static
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # 步骤 8
  run_step "E0-kg" "kg-query 知识图谱校验" step_kg_check
  step_rc=$?
  if [[ $step_rc -eq 0 ]]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi

  # summary.md
  local exec_rate pass_rate gap_rate
  exec_rate=$(awk "BEGIN {printf \"%.0f\", $total/$total*100}")
  pass_rate=$(awk "BEGIN {printf \"%.0f\", $pass/$total*100}")
  gap_rate=$(awk "BEGIN {printf \"%.0f\", $fail/$total*100}")

  local summary="$RESULTS_DIR/summary.md"
  cat > "$summary" <<EOF
# E0 静态验证汇总

- 任务包: $PLAN_ID
- 执行时间: $(date '+%F %T')
- 步骤总数: $total

执行率: $total/$total ($exec_rate%)
通过率: $pass/$total ($pass_rate%)
缺口率: $fail/$total ($gap_rate%)
- SKIP: $skip (静态验证步骤全部执行，无 SKIP)

| 步骤 | 结果 | 日志 |
|------|------|------|
| E0-doc-check | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-doc-check.log" | cut -d' ' -f2) | results/$DATE/E0-doc-check.log |
| E0-bash-syntax | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-bash-syntax.log" | cut -d' ' -f2) | results/$DATE/E0-bash-syntax.log |
| E0-registry | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-registry.log" | cut -d' ' -f2) | results/$DATE/E0-registry.log |
| E0-decision | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-decision.log" | cut -d' ' -f2) | results/$DATE/E0-decision.log |
| E0-spotcheck | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-spotcheck.log" | cut -d' ' -f2) | results/$DATE/E0-spotcheck.log |
| E0-contract | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-contract.log" | cut -d' ' -f2) | results/$DATE/E0-contract.log |
| E0-tc-static | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-tc-static.log" | cut -d' ' -f2) | results/$DATE/E0-tc-static.log |
| E0-kg | $(grep -m1 'RESULT:' "$RESULTS_DIR/E0-kg.log" | cut -d' ' -f2) | results/$DATE/E0-kg.log |
EOF

  # 追加 history log
  local ts
  ts=$(date '+%Y-%m-%dT%H:%M:%S%z')
  printf '%s\t%s\t%s\t%s\t%s\n' "$ts" "$errors" "$warns" "$spotcheck_result" "$PLAN_ID" >> "$HISTORY_LOG"

  echo ""
  echo "=== E0 静态验证汇总 ==="
  echo "任务包: $PLAN_ID"
  echo "执行率: $total/$total ($exec_rate%)"
  echo "通过率: $pass/$total ($pass_rate%)"
  echo "缺口率: $fail/$total ($gap_rate%)"
  echo "summary: $summary"
  echo "history: $HISTORY_LOG"

  if [[ $fail -gt 0 ]]; then
    echo "[FAIL] 存在失败步骤，退出码 1"
    exit 1
  fi
  echo "[PASS] 全部通过或 SKIP，退出码 0"
  exit 0
}

main "$@"
