#!/bin/bash
# 决策一致性与概念卡片校验脚本
# 用法: doc-decision-check.sh [--strict]
# 功能:
#   1. 检测 decision-registry.tsv 中同一 question 是否存在多个 verdict（注册表内一致性）
#   2. 检查 source_doc 引用的文档是否存在
#   3. 检查 verdict 中提到的关键系统名是否出现在 source_doc 文件中
#   4. 若 01-58 概念卡片存在，检查其表格行六列缺项
# 退出码: 0=通过；--strict 且 ERROR>0 时 1；非 strict 时 ERROR 不影响退出码
set -u

STRICT=0
if [ "${1:-}" = "--strict" ]; then
  STRICT=1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REGISTRY="$SCRIPT_DIR/decision-registry.tsv"

ERRORS=0
WARNS=0
CONFLICTS=0

err()  { echo "[ERROR] $1"; ERRORS=$((ERRORS+1)); }
warn() { echo "[WARN]  $1"; WARNS=$((WARNS+1)); }
info() { echo "[INFO]  $1"; }

info "决策一致性与概念卡片校验开始"

# ---------- 0. 注册表存在性 ----------
if [ ! -f "$REGISTRY" ]; then
  err "决策注册表不存在: $REGISTRY"
  echo "============================="
  echo "CONFLICTS=$CONFLICTS WARN=$WARNS ERROR=$ERRORS"
  exit 1
fi

# 辅助：根据 source_doc 中的文档编号定位真实文件
# source_doc 形如 01-19#1.19.2，提取 01-19 后在 topics/ 下匹配前缀
resolve_doc() {
  local ref="$1"
  local docid="${ref%%#*}"
  if [ -z "$docid" ]; then
    echo ""
    return
  fi
  find "$ROOT/topics" -type f -name "${docid}-*.md" 2>/dev/null | head -n 1
}

# ---------- 1. 决策冲突检测（按 question 分组） ----------
info "决策冲突检测"
# 读取非注释、非空行，取第 2 列 question 与第 3 列 verdict
declare -A Q_VERDICTS
declare -A Q_IDS
while IFS=$'\t' read -r decision_id question verdict source_doc subtree; do
  # 跳过注释与表头
  case "$decision_id" in
    ''|\#*) continue ;;
  esac
  # 以 question+verdict 作为唯一键；若同一 question 出现不同 verdict 则记录
  if [ -n "${Q_VERDICTS[$question]:-}" ]; then
    if [ "${Q_VERDICTS[$question]}" != "$verdict" ]; then
      Q_IDS[$question]="${Q_IDS[$question]:-} $decision_id"
    fi
  else
    Q_VERDICTS[$question]="$verdict"
    Q_IDS[$question]="$decision_id"
  fi
done < "$REGISTRY"

for q in "${!Q_IDS[@]}"; do
  ids="${Q_IDS[$q]}"
  # 只有出现多个不同 verdict 时 ids 才会累加多个 decision_id
  count=$(echo "$ids" | wc -w)
  if [ "$count" -gt 1 ]; then
    CONFLICTS=$((CONFLICTS+1))
    warn "决策冲突: question='$q' 存在多个 verdict (${ids})"
  fi
done

# ---------- 2. 出处存在性 + 3. 结论回查 ----------
info "出处存在性与结论回查"
SYSTEMS=(Kafka RabbitMQ NATS Pulsar MQTT Redis)
while IFS=$'\t' read -r decision_id question verdict source_doc subtree; do
  case "$decision_id" in
    ''|\#*) continue ;;
  esac

  docfile=$(resolve_doc "$source_doc")
  if [ -z "$docfile" ] || [ ! -f "$docfile" ]; then
    err "出处文档不存在: $decision_id -> $source_doc"
    continue
  fi

  # 结论回查：verdict 中出现的关键系统名应在 source_doc 文件中出现
  for sys in "${SYSTEMS[@]}"; do
    if echo "$verdict" | grep -qi "$sys"; then
      if ! grep -qi "$sys" "$docfile"; then
        warn "结论回查失败: $decision_id 推荐 '$sys'，但在 $source_doc 文件中未出现"
      fi
    fi
  done
done < "$REGISTRY"

# ---------- 4. 概念卡片完整性（若 01-58 存在） ----------
CONCEPT_CARD="$ROOT/topics/01-基础概念与对比分析/01-58-全局核心概念卡片总表.md"
if [ -f "$CONCEPT_CARD" ]; then
  info "概念卡片完整性检查"
  missing=0
  while IFS= read -r line; do
    # 仅处理 Markdown 表格行（以 | 开头和结尾）
    case "$line" in
      '|'*'|') ;;
      *) continue ;;
    esac
    # 跳过分隔行（字段全为 - 或 : 对齐标记）
    if echo "$line" | grep -qE '^\|[[:space:]]*[-:]+[[:space:]]*(\|[[:space:]]*[-:]+[[:space:]]*)+\|$'; then
      continue
    fi
    # 统计管道数；六列表格应有 7 个 |（含首尾）
    pipe_count=$(echo "$line" | tr -cd '|' | wc -c)
    [ "$pipe_count" -ne 7 ] && continue
    # 拆分六列并检查是否有空单元格
    empty=$(echo "$line" | awk -F'|' '
      NF==8 {
        empty=0
        for (i=2; i<=7; i++) {
          gsub(/^[ \t]+|[ \t]+$/,"",$i)
          if ($i=="") empty=1
        }
        print empty
      }
    ')
    [ "$empty" = "1" ] && missing=$((missing+1))
  done < "$CONCEPT_CARD"
  if [ "$missing" -gt 0 ]; then
    warn "概念卡片六列表格缺项行数: $missing"
  fi
else
  info "01-58 全局核心概念卡片总表不存在，跳过完整性检查"
fi

# ---------- 汇总 ----------
echo "============================="
echo "CONFLICTS=$CONFLICTS WARN=$WARNS ERROR=$ERRORS"
if [ "$STRICT" -eq 1 ] && [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
exit 0
