#!/usr/bin/env bash
# TC-SEM-05 死信路径验证（RabbitMQ DLX，ASE-007 族）
# 关联：ASE-007；场景：03-业务场景/04-notification（retryable=false 死信段）
# 环境：E2 docker；真实执行前置：hermes-env-precheck.sh E2 可用 + fixtures compose rabbitmq 实例
# 用法：tc-sem-05-dlq-rabbitmq.sh [--live]
# 默认 dry-run：打印执行计划退出 0；--live 执行真实断言（需用户在场授权）
set -u
LIVE=0; [[ "${1:-}" == "--live" ]] && LIVE=1

cat <<'PLAN'
执行计划（dry-run）：
 1. compose 起 rabbitmq（fixtures/docker-compose-test-env.yml rabbitmq profile）
 2. 声明业务队列 q.biz + DLX dlx.biz（TTL 0，binding 到 q.dlq）
 3. 投递消息 m1；消费者 nack(requeue=false) 一次
 4. 断言：m1 进入 q.dlq（ASE-007：DLQ 深度=1 且原队列深度=0）
 5. 从 q.dlq 消费成功 → 断言可再处理
 产物：results/<date>/E2-TC-SEM-05.json + failbundle（失败时）
PLAN

[[ $LIVE -eq 0 ]] && { echo "DRY-RUN 完成；--live 需用户在场"; exit 0; }

echo "LIVE 模式：前置预检"
if ! bash "$(dirname "$0")/../../topics/scripts/hermes-env-precheck.sh" --quiet 2>/dev/null | grep -q "E0=AVAIL"; then
  echo "FAIL: 环境预检未过"; exit 1
fi
command -v docker >/dev/null 2>&1 || { echo "FAIL: E2 docker 不可用（TEST-09 降级口径：记 SKIP）"; exit 2; }

PLAN_ID="TC-SEM-05-$(date +%Y%m%d)"
echo "LIVE 骨架已就位（断言实现随真实首跑批次补全）：将按上方计划执行"
echo "RESULT: SKIP"; echo "DURATION: 0"; echo "EXIT_CODE: 2"
exit 2
