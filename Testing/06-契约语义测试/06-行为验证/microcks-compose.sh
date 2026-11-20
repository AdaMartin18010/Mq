#!/usr/bin/env bash
# Microcks 环境编排（TC-CON-01/02 执行器，批次78）
# 默认 dry-run：打印将执行的 compose 命令与 spec 导入清单；--live 需用户在场
set -u
# 容器运行时: podman 首选, docker 回退（TEST-09 E1/E2 双轨, 可用 MQ_RUNTIME 覆盖）
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"
LIVE=0; [[ "${1:-}" == "--live" ]] && LIVE=1
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
command -v cygpath >/dev/null 2>&1 && ROOT="$(cygpath -m "$ROOT")"
COMPOSE="$ROOT/Testing/fixtures/docker-compose-microcks.yml"
SPECS_DIR="$ROOT/Testing/06-契约语义测试/03-业务场景"

cat <<PLAN
执行计划（dry-run）：
 1. $RT compose -f Testing/fixtures/docker-compose-microcks.yml up -d（runtime=$RT）
 2. 等待 healthcheck（microcks:8580）
 3. 导入 8 个场景 spec：
$(for d in "$SPECS_DIR"/*/; do [ -f "$d/asyncapi.yaml" ] && echo "    - Testing/06-契约语义测试/03-业务场景/$(basename "$d")/asyncapi.yaml"; done)
 4. contract test 挂接 E1/E2 broker（TC-CON-01 E1 / TC-CON-02 E2）
PLAN

[[ $LIVE -eq 0 ]] && { echo "DRY-RUN 完成；--live 需用户在场"; exit 0; }
[[ -n "$RT" ]] || { echo "FAIL: 无容器运行时（podman/docker）"; exit 2; }
echo "LIVE：启动 Microcks（首次拉镜像较久, runtime=$RT）"
"$RT" compose -f "$COMPOSE" up -d
echo "RESULT: SKIP"; echo "DURATION: 0"; echo "EXIT_CODE: 2"
exit 2
