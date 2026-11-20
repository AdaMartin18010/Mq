#!/usr/bin/env bash
# spec-validate-check.sh — AsyncAPI spec 校验门（L6-02 DSL schema 校验）
#
# 用法: bash topics/scripts/spec-validate-check.sh
#   自动发现仓内全部 AsyncAPI spec（git 跟踪），逐件跑 @asyncapi/parser 3.x 校验
#
# 退出码:
#   0 = 全部通过
#   1 = 存在 schema/$ref 缺陷（明细见输出）
#   4 = 工具链不可用（node 缺失或依赖安装失败）
#
# 依赖: node >= 18; Testing/asyncapi-tools/node_modules（缺失时自动 npm install）
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROOT_W="$(cygpath -m "$ROOT")"   # node 是 Windows 原生程序，须 Windows 风格路径
TOOL="$ROOT/Testing/asyncapi-tools"
TOOL_W="$(cygpath -m "$TOOL")"

if ! command -v node >/dev/null 2>&1; then
  echo "[spec-validate] FATAL: node 不可用（L6-02 降级：跳过，不阻断）"
  exit 4
fi
if [ ! -d "$TOOL_W/node_modules/@asyncapi/parser" ] && [ ! -d "$TOOL/node_modules/@asyncapi/parser" ]; then
  echo "[spec-validate] node_modules 缺失，执行 npm install..."
  (cd "$TOOL" && npm install --no-audit --no-fund --loglevel=error) || {
    echo "[spec-validate] FATAL: npm install 失败（离线环境？）"
    exit 4
  }
fi

# spec 发现：git 跟踪的 AsyncAPI 文档（排除 contract.yaml/spectral 规则等非 AsyncAPI 件）
mapfile -t SPECS < <(cd "$ROOT" && git ls-files -z | tr '\0' '\n' \
  | grep -E '(^|/)asyncapi.*\.ya?ml$' \
  | grep -vE '(contract\.ya?ml|spectral-)' )

if [ "${#SPECS[@]}" -eq 0 ]; then
  echo "[spec-validate] 未发现任何 AsyncAPI spec（异常）"
  exit 4
fi

echo "[spec-validate] 发现 ${#SPECS[@]} 件 spec，执行 @asyncapi/parser 校验..."
ABS=()
for s in "${SPECS[@]}"; do ABS+=("$ROOT_W/$s"); done

OUT="$(cd "$TOOL" && node "$TOOL_W/spec-validate.js" "${ABS[@]}" 2>&1)"
RC=$?

FAIL=0
while IFS= read -r line; do
  case "$line" in
    *'"ok":false'*) FAIL=$((FAIL+1));;
  esac
done <<< "$OUT"

echo "$OUT"
echo "============================="
if [ "$RC" -eq 4 ]; then
  echo "[spec-validate] FATAL: 工具链异常（RC=4），降级跳过"
  exit 4
fi
if [ $FAIL -eq 0 ] && [ "$RC" -eq 0 ]; then
  echo "汇总: ${#SPECS[@]}/${#SPECS[@]} 通过 (RC=$RC)"
  echo "[spec-validate] ✅ AsyncAPI schema 校验通过"
  exit 0
else
  echo "汇总: ${FAIL}/${#SPECS[@]} 存在 schema 缺陷"
  echo "[spec-validate] ❌ AsyncAPI schema 校验失败"
  exit 1
fi
