#!/usr/bin/env bash
# spec-diff-check.sh — L6（业务场景→测试验证环）spec 版本差分 / breaking change 检测
# 工具链: Testing/asyncapi-tools/（@asyncapi/diff 0.6.1，npm 安装；node_modules gitignore）
# 用法: spec-diff-check.sh <old.yaml> <new.yaml>
# 退出码: 0=无 breaking / 1=有 breaking / 2=参数错 / 3=工具错 / 4=node 缺失
set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_DIR="$PROJECT_ROOT/Testing/asyncapi-tools"

if [ "$#" -lt 2 ]; then
  echo "usage: spec-diff-check.sh <old.yaml> <new.yaml>"
  exit 2
fi

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node 未安装（L6 diff 需 node 环境）"
  exit 4
fi

if [ ! -d "$TOOLS_DIR/node_modules/@asyncapi/diff" ]; then
  echo "INFO: 首跑安装 @asyncapi/diff 0.6.1 ..."
  (cd "$TOOLS_DIR" && npm install --no-audit --no-fund) || { echo "FAIL: npm install 失败"; exit 3; }
fi

# node 为原生程序: MSYS 路径归一为 Windows 风格（cygpath 对已是原生路径的参数为幂等 no-op）
OLD="$1"
NEW="$2"
if command -v cygpath >/dev/null 2>&1; then
  TOOLS_DIR="$(cygpath -m "$TOOLS_DIR")"
  OLD="$(cygpath -m "$OLD")"
  NEW="$(cygpath -m "$NEW")"
fi

node "$TOOLS_DIR/spec-diff.js" "$OLD" "$NEW"
rc=$?
if [ "$rc" -eq 0 ]; then
  echo "PASS: 无 breaking change"
elif [ "$rc" -eq 1 ]; then
  echo "FAIL: 检出 breaking change（见上方明细）"
fi
exit "$rc"
