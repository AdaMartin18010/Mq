#!/usr/bin/env bash
# 跨语言金样本矩阵占位执行器（TC-XLAN，批次100）
# --validate：金样本 JSONL 格式校验（python3）
# --live：全配对执行（挂真实执行集中批，本骨架只达 dry-run）
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# MSYS 路径（/c/ /e/）在 MSYS_NO_PATHCONV=1 下不被 Windows 原生 python3 识别 → cygpath 统一转换
if command -v cygpath >/dev/null 2>&1; then
  ROOT="$(cygpath -m "$ROOT")"
fi
GEN="$ROOT/Testing/fixtures/generators"
LIVE=0; [[ "${1:-}" == "--live" ]] && LIVE=1

if [[ $LIVE -eq 0 && "${1:-}" != "--validate" ]]; then
  cat <<PLAN
执行计划（dry-run）：
 1. --validate 校验 8 组金样本（订单/支付/IoT/库存/通知/CDC/审计/任务队列，与 03-业务场景 01~08 对齐）JSONL 结构与边界值
 2. --live：5 语言客户端两两全配对（20 有向边）× 全部金样本
    字段级断言：值 / 类型 / 可选性
 3. 失败归类：精度损失 / 时间偏移 / 可选性坍塌 / 编码差异
PLAN
  echo "DRY-RUN 完成；--validate 可立即执行，--live 挂真实执行集中批"; exit 0
fi

if [[ "${1:-}" == "--validate" ]]; then
  rc=0
  for g in gen-orders gen-payments gen-iot-telemetry gen-inventory gen-notification gen-cdc-sync gen-audit-trail gen-task-queue; do
    python3 "$GEN/$g.py" --validate || rc=1
  done
  exit $rc
fi

echo "LIVE：全配对执行骨架就位（ fixtures 多语言容器 + Microcks 断言流随真实批次落地）"
exit 2
