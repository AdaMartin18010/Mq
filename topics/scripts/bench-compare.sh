#!/usr/bin/env bash
# 基准回归断言（批次195）：baselines.json 锚点 vs 快速重测
# 用法: bench-compare.sh --verify | --run nats|rabbit|kafka
# 退出码: 0=PASS；1=回归 FAIL（超阈值/零丢失断言破）；4=SKIP（容器未跑/工具缺失）
# 阈值口径【论证】: --run 为快速回归（15s/10 万条缩减负载），本机 WSL2 噪声大，
#   nats 速率/rabbit p50/kafka 吞吐阈值=±30%（paced 的 kafka 吞吐另设 ±15%）；
#   正式基线重采仍走 L3 审批单 §5 全量复现命令，本脚本不替代。
set -u
# MSYS_NO_PATHCONV：podman exec 传入容器内 POSIX 路径（/opt/kafka/bin/...）必须阻止 MSYS 改写为 Windows 路径（RC=127 坑）
export MSYS_NO_PATHCONV=1

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 4
BASELINES="Testing/benchmark/baselines.json"
BENCH="Testing/benchmark/mq-bench.exe"
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"

[ -f "$BASELINES" ] || { echo "FAIL: $BASELINES 缺失"; exit 1; }

# ---------- --verify：锚点文件静态自洽 ----------
verify() {
  python3 - <<'PYEOF'
import json, sys
d = json.load(open("Testing/benchmark/baselines.json", encoding="utf-8"))
errs = []
for k in ("kafka_single", "kafka_federation", "nats_rtt", "rabbitmq_e2e"):
    if k not in d: errs.append(f"缺锚点 {k}")
def chk_order(name, vals):
    if any(vals[i] > vals[i+1] for i in range(len(vals)-1)):
        errs.append(f"{name} 分位数无序: {vals}")
try:
    ks = d["kafka_single"]
    if not (ks["steady_window_range"][0] <= ks["steady_records_per_sec"] <= ks["steady_window_range"][1]):
        errs.append("kafka_single 稳态值不在窗口区间内")
    chk_order("kafka_single", [ks["full_window_avg_ms"], ks["p99_ms"], ks["p99_9_ms"], ks["max_ms"]])
    kf = d["kafka_federation"]
    if not (kf["steady_records_per_sec_range"][0] <= kf["full_window_records_per_sec"] <= kf["steady_records_per_sec_range"][1]):
        errs.append("kafka_federation 全窗口值不在稳态区间内")
    for i, r in enumerate(d["nats_rtt"]["rounds"]):
        chk_order(f"nats_rtt.round{i}", [r["avg_ms"], r["p50_ms"], r["p99_ms"], r["p99_9_ms"], r["max_ms"]])
        exp = r["requests"] / r["elapsed_s"]
        if abs(exp - r["rate_msg_s"]) / r["rate_msg_s"] > 0.01:
            errs.append(f"nats_rtt.round{i} 速率自洽偏差>1%（{exp:.1f} vs {r['rate_msg_s']}）")
    rb = d["rabbitmq_e2e"]
    chk_order("rabbitmq_e2e", [rb["p50_ms"], rb["p95_ms"], rb["p99_ms"], rb["p99_9_ms"], rb["max_ms"]])
    if rb["avg_ms"] < rb["p50_ms"]: errs.append("rabbitmq_e2e avg<p50 异常")
    if d["_meta"].get("approval") is None: errs.append("_meta.approval 缺失")
except KeyError as e:
    errs.append(f"字段缺失: {e}")
if errs:
    print("VERIFY_FAIL " + "; ".join(errs)); sys.exit(1)
print("VERIFY_OK 4 锚点静态自洽（分位序/窗口包络/速率自洽/approval 链）")
PYEOF
}

ensure_bench() {
  if [ -f "$BENCH" ]; then return 0; fi
  if command -v go >/dev/null 2>&1; then
    (cd Testing/benchmark && go build -o mq-bench.exe . ) || return 1
    return 0
  fi
  return 1
}

up() { # 容器在跑且 healthy/running
  [ -n "$RT" ] && $RT ps --format "{{.Names}}\t{{.Status}}" 2>/dev/null | grep -E "^$1\s" | grep -qiE "up|running"
}

within() { # $1=实测 $2=锚点 $3=阈值比例
  awk "BEGIN {d=$1-$2; if(d<0)d=-d; print (d/$2)<=$3 ? 0 : 1}"
}

# ---------- --run ----------
run_nats() {
  up nats-test || { echo "SKIP: nats-test 容器未在跑（weekly 不强制起栈）"; return 4; }
  ensure_bench || { echo "SKIP: mq-bench.exe 缺失且 go 不可用"; return 4; }
  local out rate p99 rc=0
  out="$("$BENCH" nats -mode rtt -dur 15 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ]; then
    if printf '%s\n' "$out" | grep -qiE "connect fail|dial fail|refused"; then
      echo "SKIP: nats broker 宿主不可达（WSL2 端口转发未建立；回归未执行≠回归失败）"
      return 4
    fi
    echo "FAIL: mq-bench nats RC=$rc"
    return 1
  fi
  rate="$(printf '%s\n' "$out" | grep -oE 'rate=[0-9.]+ msg/s' | tail -1 | grep -oE '[0-9.]+')"
  p99="$(printf '%s\n' "$out" | grep -oE 'p99=[0-9.]+' | tail -1 | cut -d= -f2)"
  [ -n "$rate" ] || { echo "FAIL: 无法解析 nats 速率输出"; return 1; }
  echo "实测 rate=${rate} msg/s p99=${p99}ms（锚点 2888.3±30%）"
  if [ "$(within "$rate" 2888.3 0.30)" -eq 0 ]; then
    echo "PASS: NATS RTT 速率回归在阈值内"
    return 0
  fi
  echo "FAIL: NATS RTT 速率回归超阈值（实测 $rate vs 锚点 2888.3）"
  return 1
}

run_rabbit() {
  up rabbitmq-test || { echo "SKIP: rabbitmq-test 容器未在跑（weekly 不强制起栈）"; return 4; }
  ensure_bench || { echo "SKIP: mq-bench.exe 缺失且 go 不可用"; return 4; }
  local out n p50 rc=0
  out="$("$BENCH" rabbit -rate 10000 -dur 15 -size 1024 2>&1)" || rc=$?
  if [ "$rc" -ne 0 ]; then
    if printf '%s\n' "$out" | grep -qiE "connect fail|dial fail|refused"; then
      echo "SKIP: rabbitmq broker 宿主不可达（WSL2 端口转发未建立；回归未执行≠回归失败）"
      return 4
    fi
    echo "FAIL: mq-bench rabbit RC=$rc"
    return 1
  fi
  n="$(printf '%s\n' "$out" | grep -oE 'n=[0-9]+ elapsed=[0-9.]+s rate=[0-9.]+' | tail -1)"
  p50="$(printf '%s\n' "$out" | grep -oE 'p50=[0-9.]+' | tail -1 | cut -d= -f2)"
  local got
  got="$(echo "$n" | grep -oE '^n=[0-9]+' | cut -d= -f2)"
  if [ -n "$got" ] && [ "$got" -lt 135000 ]; then
    echo "FAIL: rabbit e2e 收齐不足（$got/150000，零积压断言破）"
    return 1
  fi
  [ -n "$p50" ] || { echo "FAIL: 无法解析 rabbit p50"; return 1; }
  echo "实测 e2e p50=${p50}ms（$n；锚点 0.654±30%）"
  if [ "$(within "$p50" 0.654 0.30)" -eq 0 ]; then
    echo "PASS: RabbitMQ e2e p50 回归在阈值内"
    return 0
  fi
  echo "FAIL: RabbitMQ e2e p50 回归超阈值（实测 $p50 vs 锚点 0.654）"
  return 1
}

run_kafka() {
  up kafka-1 || { echo "SKIP: kafka-1 容器未在跑（weekly 不强制起栈）"; return 4; }
  local anchor=9931.0 tol=0.15 mode=单机
  if up kafka-2; then anchor=9998.0; mode=联邦; fi
  local out rps
  out="$($RT exec kafka-1 /opt/kafka/bin/kafka-producer-perf-test.sh --topic bench-regression --num-records 100000 --record-size 1024 --throughput 10000 --producer-props bootstrap.servers=kafka-1:29092 acks=all batch.size=16384 linger.ms=10 2>&1)" || { echo "FAIL: perf-test RC=$?"; return 1; }
  rps="$(printf '%s\n' "$out" | grep -oE '[0-9.]+ records/sec' | tail -1 | grep -oE '^[0-9.]+')"
  [ -n "$rps" ] || { echo "FAIL: 无法解析 kafka records/sec"; return 1; }
  echo "实测（$mode 口径）records/sec=$rps（锚点 $anchor±15%）"
  if [ "$(within "$rps" "$anchor" 0.15)" -eq 0 ]; then
    echo "PASS: Kafka producer 吞吐回归在阈值内（$mode 口径）"
    return 0
  fi
  echo "FAIL: Kafka producer 吞吐回归超阈值（实测 $rps vs 锚点 $anchor）"
  return 1
}

case "${1:-}" in
  --verify) verify ;;
  --run)
    case "${2:-}" in
      nats) run_nats ;;
      rabbit) run_rabbit ;;
      kafka) run_kafka ;;
      *) echo "用法: bench-compare.sh --run nats|rabbit|kafka" >&2; exit 2 ;;
    esac
    ;;
  *) echo "用法: bench-compare.sh --verify | --run nats|rabbit|kafka" >&2; exit 2 ;;
esac
