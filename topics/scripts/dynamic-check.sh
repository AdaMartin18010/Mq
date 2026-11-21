#!/usr/bin/env bash
# 动态验证入口（批次196，对齐 BufferCache L2.5 层）——hermes 开工自检/会话级，非 E0 门禁
# 用法: dynamic-check.sh [--all|--selfheal|--steady|--boundary|--skill]
# RC: 0=全 PASS；1=存在 FAIL（SKIP 语义由各子脚本自定；本层 fail-fast 聚合）
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1

run_one() { # $1=脚本 $2=名
  echo "----- $2 -----"
  bash "topics/scripts/$1" || return 1
  echo ""
  return 0
}

rc=0
case "${1:---all}" in
  --all)
    run_one "ops-selfheal-budget.sh" "① 自愈预算模拟" || rc=1
    run_one "config-steady-check.sh" "② 配置稳态巡检" || rc=1
    python3 topics/scripts/contract-boundary-recheck.py || rc=1
    echo ""
    run_one "skill-selftest.sh" "④ 技能动态自测" || rc=1
    ;;
  --selfheal) run_one "ops-selfheal-budget.sh" "① 自愈预算模拟" || rc=1 ;;
  --steady)   run_one "config-steady-check.sh" "② 配置稳态巡检" || rc=1 ;;
  --boundary) python3 topics/scripts/contract-boundary-recheck.py || rc=1 ;;
  --skill)    run_one "skill-selftest.sh" "④ 技能动态自测" || rc=1 ;;
  *) echo "用法: dynamic-check.sh [--all|--selfheal|--steady|--boundary|--skill]" >&2; exit 2 ;;
esac

echo "===== 动态验证汇总 ====="
if [ "$rc" -eq 0 ]; then
  echo "DYNAMIC_CHECK: PASS（<3min 会话级自检，详见各节）"
else
  echo "DYNAMIC_CHECK: FAIL（存在失败节，见上）"
fi
exit "$rc"
