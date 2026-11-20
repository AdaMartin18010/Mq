#!/usr/bin/env bash
# cases/ 统一 dry-run 运行器（批次171）：打印用例计划（Given/When/Then）后以 RC=0 退出
# 用法: bash Testing/08-运维行为测试/cases/case-dryrun.sh <TC-ID> | <case.md 路径>
# 语义: dry-run = 仅计划打印，无故障注入；live 执行 = 用户在场集中批（见 06-混沌与故障注入/game-day.sh）
# 设计: 411 个 case 共用本运行器，避免 411 个逐用例 .sh 的内容重复；
#       TC-ID 经 find 解析到唯一 case.md（ID 全库唯一，见批次171证据）
set -u
CASE="${1:-}"
[[ -n "$CASE" ]] || { echo "usage: case-dryrun.sh <TC-ID | case.md 路径>"; exit 2; }

if [[ ! -f "$CASE" ]]; then
  FOUND="$(find . -path '*cases/*' -name "${CASE}.md" 2>/dev/null)"
  N="$(printf '%s' "$FOUND" | grep -c . || true)"
  [[ "$N" -eq 1 ]] || { echo "FAIL: case 未唯一解析: $1 (命中 $N)"; exit 1; }
  CASE="$FOUND"
fi
[[ -f "$CASE" ]] || { echo "FAIL: case 不存在: $1"; exit 1; }

echo "DRY-RUN $(basename "$CASE" .md)"
# 头部（标题+元数据块，至首个 ## 节为止）
awk '/^## /{exit} {print}' "$CASE"
# 计划段：Given/When/Then（至 ## Dry-run 为止）
awk '/^## Given/{f=1} /^## Dry-run/{f=0} f' "$CASE"
echo "RESULT: SKIP (dry-run: 仅计划打印，无故障注入; live = 用户在场集中批)"
echo "EXIT_CODE: 0"
exit 0
