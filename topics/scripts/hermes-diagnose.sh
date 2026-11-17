#!/usr/bin/env bash
# hermes 失败模式诊断脚本（TEST-11 §T.11.3 实现）
# 用法：hermes-diagnose.sh CASE_ID ENV [PORT|TOPIC]
# 环境变量：RUNTIME=docker|podman（默认 docker）；PLAN_ID（任务包 ID，缺省用日期）
# 输出：机器可读诊断标签，容器日志追加到 results/$PLAN_ID/$ENV-$CASE_ID.log。
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

usage() {
  cat <<'EOF'
用法: hermes-diagnose.sh CASE_ID ENV [PORT|TOPIC]
  CASE_ID       用例 ID，如 TC-DEP-01
  ENV           环境标记，如 E0/E1/E2/E3
  PORT|TOPIC    诊断端口或主题名（默认 9092 / test-topic）
环境变量:
  RUNTIME=docker|podman   容器运行时（默认 docker）
  PLAN_ID=...             任务包 ID（默认 YYYY-MM-DD）
EOF
}

if [[ "$#" -lt 2 ]] || [[ "$1" == "--help" || "$1" == "-h" ]]; then
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage; exit 0
  fi
  echo "[ERROR] 参数不足"; usage; exit 2
fi

CASE_ID="$1"
ENV="$2"
ARG3="${3:-}"
RUNTIME="${RUNTIME:-docker}"
PLAN_ID="${PLAN_ID:-$(date +%Y-%m-%d)}"
LOG_DIR="$PROJECT_ROOT/results/$PLAN_ID"
LOG="$LOG_DIR/$ENV-$CASE_ID.log"

mkdir -p "$LOG_DIR"
: >> "$LOG"

# 容器诊断：inspect Status|ExitCode|Error，并追加 logs --tail 50
diagnose_container() {
  local c
  if ! command -v "$RUNTIME" >/dev/null 2>&1; then
    echo "NO_CONTAINER"
    return
  fi
  c="$($RUNTIME ps -aqf "name=$CASE_ID" 2>/dev/null | head -1 || true)"
  if [[ -z "$c" ]]; then
    # 扩大范围查找 hermes/mq-test 相关容器
    c="$($RUNTIME ps -aq --filter "label=mq-test" 2>/dev/null | head -1 || true)"
  fi
  if [[ -z "$c" ]]; then
    echo "NO_CONTAINER"
    return
  fi
  local state
  state="$($RUNTIME inspect --format='{{.State.Status}}|{{.State.ExitCode}}|{{.State.Error}}' "$c" 2>/dev/null || echo "unknown|-1|unknown")"
  echo "CONTAINER:$state"
  {
    echo "--- container logs $c ---"
    $RUNTIME logs --tail 50 "$c" 2>&1 || true
  } >> "$LOG"
}

# 端口诊断：Git Bash 下 ss 不可用，用 netstat -ano 回退
# 输出 PORT_CONFLICT:port 或 PORT_OK:port
diagnose_port() {
  local port="${ARG3:-9092}"
  local conflict=0
  if command -v ss >/dev/null 2>&1; then
    if ss -tlnp 2>/dev/null | grep -qE ":[[:space:]]*${port}[[:space:]]"; then
      conflict=1
    fi
  elif command -v netstat >/dev/null 2>&1; then
    # Windows Git Bash 路径下存在 netstat
    if netstat -ano 2>/dev/null | grep -qE "0\.0\.0\.0:${port}|127\.0\.0\.1:${port}|\[::\]:${port}"; then
      conflict=1
    fi
  elif (echo >/dev/tcp/127.0.0.1/"$port") >/dev/null 2>&1; then
    conflict=1
  fi

  if [[ "$conflict" -eq 1 ]]; then
    echo "PORT_CONFLICT:$port"
    {
      echo "--- port conflict $port ---"
      if command -v ss >/dev/null 2>&1; then
        ss -tlnp 2>/dev/null | grep ":$port " || true
      elif command -v netstat >/dev/null 2>&1; then
        netstat -ano 2>/dev/null | grep -E ":$port " || true
      fi
    } >> "$LOG"
  else
    echo "PORT_OK:$port"
  fi
}

# 消息积压诊断：依次 best-effort 尝试 kafka/nats/rabbitmq
diagnose_lag() {
  local topic_or_group="${ARG3:-test-topic}"
  local lag_tool_found=0
  local lag_output=""

  # Kafka
  if command -v kafka-consumer-groups.sh >/dev/null 2>&1; then
    lag_tool_found=1
    lag_output="$(kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
      --describe --group "$CASE_ID" 2>/dev/null | tail -n +2 || true)"
    if [[ -n "$lag_output" ]]; then
      echo "LAG:kafka|$CASE_ID|$lag_output"
      return
    fi
  fi

  # NATS
  if command -v nats >/dev/null 2>&1; then
    lag_tool_found=1
    lag_output="$(nats consumer info "$topic_or_group" "$CASE_ID" -s nats://localhost:4222 2>/dev/null || true)"
    if [[ -n "$lag_output" ]]; then
      echo "LAG:nats|$topic_or_group|$CASE_ID"
      return
    fi
  fi

  # RabbitMQ
  if command -v rabbitmqctl >/dev/null 2>&1; then
    lag_tool_found=1
    lag_output="$(rabbitmqctl list_queues name messages messages_ready messages_unacknowledged 2>/dev/null | grep -E "$topic_or_group" || true)"
    if [[ -n "$lag_output" ]]; then
      echo "LAG:rabbitmq|$topic_or_group|$lag_output"
      return
    fi
  fi

  if [[ "$lag_tool_found" -eq 0 ]]; then
    echo "NO_LAG_TOOL"
  else
    echo "LAG:NONE"
  fi
}

# 执行三类诊断
diagnose_container
diagnose_port
diagnose_lag
