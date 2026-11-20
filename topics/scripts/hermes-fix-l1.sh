#!/usr/bin/env bash
# hermes L1 级修复脚本（TEST-11 §T.11.3 实现）
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"
# 用途：清理本任务包创建的测试残留容器/卷，并在安全校验后释放测试端口。
# 用法：hermes-fix-l1.sh PLAN_ID [--dry-run]
# 权限：严格按 L1 白名单执行；所有动作写入 Testing/hermes-audit.log。
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AUDIT_LOG="$PROJECT_ROOT/Testing/hermes-audit.log"
RUNTIME="${RUNTIME:-docker}"
DRY_RUN=0

usage() {
  cat <<'EOF'
用法: hermes-fix-l1.sh PLAN_ID [--dry-run]
  PLAN_ID     任务包 ID，用于匹配 label=hermes.run=$PLAN_ID
  --dry-run   只打印不执行
EOF
}

if [[ "$#" -lt 1 ]]; then
  echo "[ERROR] 缺少 PLAN_ID"; usage; exit 2
fi

PLAN_ID="$1"
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] 未知参数: $1"; usage; exit 2 ;;
  esac
done

# 初始化审计日志（若不存在）
if [[ ! -f "$AUDIT_LOG" ]]; then
  echo -e "# timestamp\tplan_id\tcase_id\tdiag_label\taction\trollback_cmd\toperator" > "$AUDIT_LOG"
fi

TS() { date +%Y-%m-%dT%H:%M:%S%z; }
OPERATOR="hermes"

audit() {
  local case_id="$1" diag_label="$2" action="$3" rollback="$4"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(TS)" "$PLAN_ID" "$case_id" "$diag_label" "$action" "$rollback" "$OPERATOR" >> "$AUDIT_LOG"
}

CLEANED=0
SKIP_KILLS=0

# 仅当命令存在时才执行容器操作；无容器运行时 dry-run 仍可展示意图
have_runtime() { command -v "$RUNTIME" >/dev/null 2>&1; }

# 清理 label=hermes.run=$PLAN_ID 或 label=mq-test 的容器/卷
for label in "hermes.run=$PLAN_ID" "mq-test"; do
  if have_runtime; then
    # 容器
    while IFS= read -r cid; do
      [[ -z "$cid" ]] && continue
      local name
      name="$($RUNTIME inspect --format='{{.Names}}' "$cid" 2>/dev/null | sed 's|^/||')"
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "DRY_RUN: $RUNTIME rm -f $name"
      else
        $RUNTIME rm -f "$cid" >/dev/null 2>&1 && {
          echo "CLEANED_CONTAINER: $name"
          audit "L1" "container_stuck" "rm -f $name" "$RUNTIME run ... # 需手动重建"
          CLEANED=$((CLEANED + 1))
        } || echo "FAIL_CONTAINER: $name"
      fi
    done < <($RUNTIME ps -qf "label=$label" 2>/dev/null || true)

    # 卷（docker volume 不支持 label 过滤，需先 list 再 inspect 匹配）
    if [[ "$RUNTIME" == "docker" ]]; then
      while IFS= read -r vol; do
        [[ -z "$vol" ]] && continue
        if $RT volume inspect "$vol" 2>/dev/null | grep -qE "\"$label\"|\"$PLAN_ID\""; then
          if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "DRY_RUN: $RT volume rm -f $vol"
          else
            $RT volume rm -f "$vol" >/dev/null 2>&1 && {
              echo "CLEANED_VOLUME: $vol"
              audit "L1" "leftover_volume" "volume rm -f $vol" "从 compose/backup 恢复卷数据"
              CLEANED=$((CLEANED + 1))
            } || echo "FAIL_VOLUME: $vol"
          fi
        fi
      done < <($RT volume ls -q 2>/dev/null || true)
    elif [[ "$RUNTIME" == "podman" ]]; then
      while IFS= read -r vol; do
        [[ -z "$vol" ]] && continue
        if podman volume inspect "$vol" --format '{{.Labels}}' 2>/dev/null | grep -qE "$label|$PLAN_ID"; then
          if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "DRY_RUN: podman volume rm -f $vol"
          else
            podman volume rm -f "$vol" >/dev/null 2>&1 && {
              echo "CLEANED_VOLUME: $vol"
              audit "L1" "leftover_volume" "volume rm -f $vol" "从 compose/backup 恢复卷数据"
              CLEANED=$((CLEANED + 1))
            } || echo "FAIL_VOLUME: $vol"
          fi
        fi
      done < <(podman volume ls -q 2>/dev/null || true)
    fi
  else
    echo "SKIP_RUNTIME: $RUNTIME 不可用"
  fi
done

# 释放常见测试端口：仅当占用进程命令行含测试 broker 特征串且路径含 results|temp|test|fixture 时才 kill
# Guard 不满足则跳过并记录 SKIP_KILL:port
is_test_broker_process() {
  local pid="$1"
  local cmdline pathinfo
  # 读取 /proc/$pid/cmdline（Linux），Windows Git Bash 无 /proc，则用 ps 回退
  if [[ -r "/proc/$pid/cmdline" ]]; then
    cmdline="$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)"
  else
    cmdline="$(ps -p "$pid" -o args= 2>/dev/null || true)"
  fi
  pathinfo="$(pwdx "$pid" 2>/dev/null || true)"
  [[ -z "$pathinfo" ]] && pathinfo="$(ps -p "$pid" -o pwd= 2>/dev/null || true)"

  if echo "$cmdline" | grep -qiE "kafka|nats|rabbitmq|redis|pulsar"; then
    if echo "$cmdline $pathinfo" | grep -qiE "results|temp|test|fixture"; then
      return 0
    fi
  fi
  return 1
}

for port in 9092 4222 5672 15672 6379 6650 8080; do
  pids=""
  if command -v ss >/dev/null 2>&1; then
    pids="$(ss -tlnp 2>/dev/null | grep ":$port " | sed -n 's/.*pid=\([0-9]*\).*/\1/p' | sort -u || true)"
  elif command -v netstat >/dev/null 2>&1; then
    # Windows netstat -ano 最后一列为 PID
    pids="$(netstat -ano 2>/dev/null | awk -v p="$port" '$0 ~ ":"p" " {print $NF}' | sort -u || true)"
  fi

  if [[ -z "$pids" ]]; then
    continue
  fi

  any_killed=0
  while IFS= read -r pid; do
    [[ -z "$pid" || ! "$pid" =~ ^[0-9]+$ ]] && continue
    if is_test_broker_process "$pid"; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "DRY_RUN: kill $pid (port $port)"
        any_killed=1
      else
        if kill "$pid" 2>/dev/null; then
          echo "KILLED_PORT: $port pid=$pid"
          audit "L1" "port_conflict" "kill $pid (port $port)" "重新启动原测试进程"
          CLEANED=$((CLEANED + 1))
          any_killed=1
        else
          echo "FAIL_KILL: $port pid=$pid"
        fi
      fi
    else
      echo "SKIP_KILL:$port pid=$pid (Guard 不满足：非测试 broker 进程)"
      SKIP_KILLS=$((SKIP_KILLS + 1))
    fi
  done <<< "$pids"
done

echo "SUMMARY: cleaned=$CLEANED skip_kills=$SKIP_KILLS"
