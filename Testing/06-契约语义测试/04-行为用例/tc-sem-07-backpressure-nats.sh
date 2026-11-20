#!/usr/bin/env bash
# TC-SEM-07 背压平台期验证（NATS JetStream maxAckPending，ASE-010 族）
# 关联：ASE-010/011；场景：03-业务场景/03-inventory（大促背压段）
# 环境：E1 podman / E2 docker（podman 首选）；真实执行前置：hermes-env-precheck.sh + nats server with JetStream
# 用法：tc-sem-07-backpressure-nats.sh [--live]
# 默认 dry-run：打印执行计划退出 0；--live 执行真实断言（需用户在场授权）
set -u
# 容器运行时：podman 首选，docker 回退（TEST-09 E1/E2 双轨，可用 MQ_RUNTIME 覆盖）
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"
LIVE=0; [[ "${1:-}" == "--live" ]] && LIVE=1

cat <<'PLAN'
执行计划（dry-run）：
 1. 起 nats -js（fixtures/docker-compose-test-env.yml nats profile）
 2. 建 stream BPTEST（workqueue）+ durable pull consumer，maxAckPending=100
 3. 生产端持续投递 500 条；消费端消费但不 ack
 4. 采样 pending 数曲线（nats consumer info），断言平台期=100（ASE-010）
 5. 断言消费进程 RSS 平稳（无 OOM 增长趋势）
 产物：results/<date>/E2-TC-SEM-07.json + pending 曲线数据
PLAN

[[ $LIVE -eq 0 ]] && { echo "DRY-RUN 完成；--live 需用户在场"; exit 0; }

echo "LIVE 模式：前置预检"
bash "$(dirname "$0")/../../../topics/scripts/hermes-env-precheck.sh" --quiet 2>/dev/null | grep -q "E0=AVAIL" || { echo "FAIL: 环境预检未过"; exit 1; }
[[ -n "$RT" ]] || { echo "FAIL: 无容器运行时（podman/docker）（记 SKIP）"; exit 2; }

echo "LIVE 骨架已就位（断言实现随真实首跑批次补全）"
echo "RESULT: SKIP"; echo "DURATION: 0"; echo "EXIT_CODE: 2"
exit 2
