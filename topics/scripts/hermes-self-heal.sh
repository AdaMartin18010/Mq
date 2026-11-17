#!/usr/bin/env bash
# hermes 分级自愈决策脚本（TEST-11 §T.11.2 / §T.11.4 实现）
# 用法：hermes-self-heal.sh DIAG [PLAN_ID CASE_ID]
# 说明：按诊断标签映射到 L0-L3 级别；L3 只生成审批单，绝不自动执行修复。
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIT_LOG="$PROJECT_ROOT/Testing/hermes-audit.log"

usage() {
  cat <<'EOF'
用法: hermes-self-heal.sh DIAG [PLAN_ID CASE_ID]
  DIAG      诊断标签，如 container_stuck / config_drift / doc_drift
  PLAN_ID   任务包 ID（可选）
  CASE_ID   用例 ID（可选）
EOF
}

if [[ "$#" -lt 1 ]]; then
  echo "[ERROR] 缺少 DIAG"; usage; exit 2
fi

DIAG="$1"
PLAN_ID="${2:-$(date +%Y-%m-%d)}"
CASE_ID="${3:-UNKNOWN}"

LEVEL="L0"
case "$DIAG" in
  container_stuck|port_conflict|leftover_volume|flaky_network)
    LEVEL="L1" ;;
  config_drift|fixture_outdated|env_timeout)
    LEVEL="L2" ;;
  doc_drift|test_assertion_bug|script_logic_bug)
    LEVEL="L3" ;;
  *)
    LEVEL="L0" ;;
esac

TS() { date +%Y-%m-%dT%H:%M:%S%z; }
TIMESTAMP="$(TS)"
APPROVAL_DIR="$PROJECT_ROOT/results/l3-approvals"
mkdir -p "$APPROVAL_DIR"

# 初始化审计日志（若不存在）
if [[ ! -f "$AUDIT_LOG" ]]; then
  echo -e "# timestamp\tplan_id\tcase_id\tdiag_label\taction\trollback_cmd\toperator" > "$AUDIT_LOG"
fi

audit() {
  local action="$1" rollback="$2" operator="${3:-hermes}"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$TIMESTAMP" "$PLAN_ID" "$CASE_ID" "$DIAG" "$action" "$rollback" "$operator" >> "$AUDIT_LOG"
}

# L3：生成审批单，禁止自动执行
if [[ "$LEVEL" == "L3" ]]; then
  echo "L3_MANUAL_REVIEW_REQUIRED: $DIAG"

  classification="D"
  case "$DIAG" in
    test_assertion_bug) classification="T" ;;
    script_logic_bug)   classification="E" ;;
    doc_drift)          classification="D" ;;
  esac

  approval_file="$APPROVAL_DIR/${DIAG}-${TIMESTAMP}.md"
  # 去除文件名中的冒号
  approval_file="${approval_file//:/-}"

  cat > "$approval_file" <<EOF
## hermes L3 修复审批单

- 任务包: ${PLAN_ID}
- 用例: ${CASE_ID}
- 分类: ${classification}（${DIAG}）
- 拟修改文件: __________
- 回滚方案: git checkout <file> 上一提交 或 git revert <commit>
- 回归用例: ${CASE_ID}
- 审批人: __________  日期: __________

## 修复说明

请在此补充：
1. 失败现象与诊断标签对照；
2. 文档/断言/脚本需要修改的具体位置；
3. 双人复核记录；
4. 回归验证结果。

## 约束声明

本审批单由 hermes-self-heal.sh 自动生成。L3 级内容修复禁止机器自动合并，必须经人工审批与 PR 流程。
EOF

  audit "生成 L3 审批单 $approval_file" "关闭审批单/不合并"
  echo "APPROVAL_FILE=$approval_file"
  exit 0
fi

# L1：调用 hermes-fix-l1.sh
if [[ "$LEVEL" == "L1" ]]; then
  echo "LEVEL=L1 ACTION=auto_fix diag=$DIAG"
  FIX_SCRIPT="$SCRIPT_DIR/hermes-fix-l1.sh"
  if [[ -x "$FIX_SCRIPT" ]]; then
    PLAN_ID="$PLAN_ID" "$FIX_SCRIPT" "$PLAN_ID"
    audit "执行 L1 修复 $DIAG" "$FIX_SCRIPT $PLAN_ID --dry-run"
  else
    echo "L1_FIX_SCRIPT_MISSING: $FIX_SCRIPT"
    audit "L1 修复脚本不可用" "手工执行 $FIX_SCRIPT $PLAN_ID"
  fi
  exit 0
fi

# L2：只输出待人工确认的配置变更 diff 建议，不自动改配置
if [[ "$LEVEL" == "L2" ]]; then
  echo "LEVEL=L2 ACTION=propose_diff diag=$DIAG"
  echo "建议操作："
  case "$DIAG" in
    config_drift)
      echo "  1. 对比 topics/config-templates/ 与 Testing/fixtures/ 中相关配置副本；"
      echo "  2. 生成 diff 后由人工确认；"
      echo "  3. 修改前执行 git stash 或 cp 备份作为回滚快照。"
      ;;
    fixture_outdated)
      echo "  1. 检查 Testing/fixtures/*.yml 与最新文档/模板是否一致；"
      echo "  2. 更新夹具并记录版本对应关系。"
      ;;
    env_timeout)
      echo "  1. 检查 hermes 任务包 timeout 参数；"
      echo "  2. 若因资源不足导致超时，扩容或降低并发度。"
      ;;
  esac
  audit "生成 L2 配置变更方案 $DIAG" "git checkout 或恢复备份"
  exit 0
fi

# L0：只输出诊断建议
echo "LEVEL=L0 ACTION=report_only diag=$DIAG"
echo "建议：收集完整日志、环境快照与失败包后转人工分析。"
audit "L0 报告 $DIAG" "人工复核后重新分级"
exit 0
