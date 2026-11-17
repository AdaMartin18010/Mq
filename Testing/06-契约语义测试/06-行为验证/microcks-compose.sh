#!/usr/bin/env bash
# Microcks 环境编排（TC-CON-01/02 执行器，批次78）
# 默认 dry-run：打印将执行的 compose 命令与 spec 导入清单；--live 需用户在场
set -u
LIVE=0; [[ "${1:-}" == "--live" ]] && LIVE=1
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE="$ROOT/Testing/fixtures/docker-compose-microcks.yml"
SPECS_DIR="$ROOT/Testing/06-契约语义测试/03-业务场景"

cat <<PLAN
执行计划（dry-run）：
 1. docker compose -f Testing/fixtures/docker-compose-microcks.yml up -d
 2. 等待 healthcheck（microcks:8580）
 3. 导入 8 个场景 spec：
$(for d in "$SPECS_DIR"/*/; do [ -f "$d/asyncapi.yaml" ] && echo "    - Testing/06-契约语义测试/03-业务场景/$(basename "$d")/asyncapi.yaml"; done)
 4. contract test 挂接 E1/E2 broker（TC-CON-01 E1 / TC-CON-02 E2）
PLAN

[[ $LIVE -eq 0 ]] && { echo "DRY-RUN 完成；--live 需用户在场"; exit 0; }
command -v docker >/dev/null 2>&1 || { echo "FAIL: docker 不可用"; exit 2; }
echo "LIVE：启动 Microcks（首次拉镜像较久）"
docker compose -f "$COMPOSE" up -d
echo "RESULT: SKIP"; echo "DURATION: 0"; echo "EXIT_CODE: 2"
exit 2
