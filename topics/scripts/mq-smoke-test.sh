#!/bin/bash
# 消息队列冒烟测试（TEST-06 配套，对应 TEST-02 TC-DEP-01~04 精简版）
# 用法: mq-smoke-test.sh [kafka|nats|rabbitmq|redis|mqtt|pulsar|all]
# 说明: Windows Git Bash 下不使用 GNU timeout（与系统 timeout 冲突），
#       全部用容器/客户端自带超时参数与后台进程显式 kill。
set -u

SYSTEM=${1:-"kafka"}
CT="$(cd "$(dirname "$0")/../config-templates" && pwd)"
PASS=0; FAIL=0; SKIP=0

say()  { echo "$1"; }
pass() { say "✅ PASS $1"; PASS=$((PASS+1)); }
fail() { say "❌ FAIL $1: $2"; FAIL=$((FAIL+1)); }
skip() { say "⏭  SKIP $1: $2"; SKIP=$((SKIP+1)); }

command -v docker >/dev/null 2>&1 || { skip "all" "无 docker"; echo "汇总: PASS=$PASS FAIL=$FAIL SKIP=$SKIP"; exit 0; }
docker info >/dev/null 2>&1 || { skip "all" "docker 守护进程不可用"; echo "汇总: PASS=$PASS FAIL=$FAIL SKIP=$SKIP"; exit 0; }

port_free() { ! (echo >/dev/tcp/127.0.0.1/"$1") 2>/dev/null; }
have_cli()  { command -v "$1" >/dev/null 2>&1; }

# ---------- Kafka ----------
smoke_kafka() {
  port_free 9092 || { skip kafka "端口 9092 被占用"; return; }
  cleanup_kafka() { docker compose -f "$CT/docker-compose-kafka.yml" down -v >/dev/null 2>&1; }
  trap cleanup_kafka RETURN
  say "[kafka 1/4] 启动容器..."
  docker compose -f "$CT/docker-compose-kafka.yml" up -d >/dev/null 2>&1 || { fail kafka "compose 启动失败"; return; }
  say "[kafka 2/4] 等待就绪..."
  local ready=0
  for _ in $(seq 1 45); do
    docker exec kafka-1 kafka-topics.sh --bootstrap-server localhost:9092 --list >/dev/null 2>&1 && { ready=1; break; }
    sleep 2
  done
  [ "$ready" = 1 ] || { fail kafka "90 秒未就绪"; return; }
  say "[kafka 3/4] 生产消费往返..."
  docker exec kafka-1 kafka-topics.sh --bootstrap-server localhost:9092 \
    --create --topic smoke-test --partitions 1 --replication-factor 1 >/dev/null 2>&1
  echo "smoke-$(date +%s)" | docker exec -i kafka-1 \
    kafka-console-producer.sh --bootstrap-server localhost:9092 --topic smoke-test >/dev/null 2>&1
  local got
  got=$(docker exec kafka-1 kafka-console-consumer.sh --bootstrap-server localhost:9092 \
        --topic smoke-test --from-beginning --max-messages 1 --timeout-ms 15000 2>/dev/null | head -1)
  if [ -n "$got" ]; then pass kafka; else fail kafka "未消费到消息"; fi
  say "[kafka 4/4] 清理..."; cleanup_kafka; trap - RETURN
}

# ---------- NATS ----------
smoke_nats() {
  port_free 4222 || { skip nats "端口 4222 被占用"; return; }
  have_cli nats || { skip nats "无 nats CLI"; return; }
  cleanup_nats() { docker compose -f "$CT/docker-compose-nats.yml" down -v >/dev/null 2>&1; rm -f /tmp/nats-sub.out; }
  trap cleanup_nats RETURN
  say "[nats 1/3] 启动容器..."
  docker compose -f "$CT/docker-compose-nats.yml" up -d >/dev/null 2>&1 || { fail nats "compose 启动失败"; return; }
  sleep 3
  say "[nats 2/3] 建流 + 收发..."
  if nats stream add SMOKE_TEST --subjects smoke.test --storage file --defaults \
       -s nats://localhost:4222 >/dev/null 2>&1; then
    local msg="smoke-$(date +%s)"
    nats sub smoke.test -s nats://localhost:4222 --count=1 > /tmp/nats-sub.out 2>/dev/null &
    local subpid=$!
    sleep 1
    nats pub smoke.test "$msg" -s nats://localhost:4222 >/dev/null 2>&1
    sleep 3
    kill "$subpid" 2>/dev/null
    if grep -q "$msg" /tmp/nats-sub.out 2>/dev/null; then pass nats; else fail nats "未收到消息"; fi
  else
    fail nats "建流失败"
  fi
  say "[nats 3/3] 清理..."; cleanup_nats; trap - RETURN
}

# ---------- RabbitMQ ----------
smoke_rabbitmq() {
  port_free 5672 || { skip rabbitmq "端口 5672 被占用"; return; }
  cleanup_mq() { docker compose -f "$CT/docker-compose-rabbitmq.yml" down -v >/dev/null 2>&1; }
  trap cleanup_mq RETURN
  say "[rabbitmq 1/3] 启动容器..."
  docker compose -f "$CT/docker-compose-rabbitmq.yml" up -d >/dev/null 2>&1 || { fail rabbitmq "compose 启动失败"; return; }
  local i
  for i in $(seq 1 30); do
    curl -s -o /dev/null http://localhost:15672 && break; sleep 2
  done
  say "[rabbitmq 2/3] 队列声明 + 收发..."
  if curl -s -u admin:admin -H "content-type:application/json" \
      -X PUT -d '{"auto_delete":false,"durable":true,"arguments":{"x-queue-type":"quorum"}}' \
      http://localhost:15672/api/queues/%2F/smoke-test >/dev/null 2>&1; then
    curl -s -u admin:admin -H "content-type:application/json" \
      -X POST -d '{"properties":{},"routing_key":"smoke-test","payload":"smoke","payload_encoding":"string"}' \
      http://localhost:15672/api/exchanges/%2F/amq.default/publish >/dev/null 2>&1
    local n
    n=$(curl -s -u admin:admin http://localhost:15672/api/queues/%2F/smoke-test 2>/dev/null | grep -o '"messages":[0-9]*' | cut -d: -f2)
    if [ "${n:-0}" -ge 1 ]; then pass rabbitmq; else fail rabbitmq "队列无消息"; fi
  else
    fail rabbitmq "队列声明失败"
  fi
  say "[rabbitmq 3/3] 清理..."; cleanup_mq; trap - RETURN
}

# ---------- Redis (Stream) ----------
smoke_redis() {
  port_free 6379 || { skip redis "端口 6379 被占用"; return; }
  say "[redis 1/3] 启动容器..."
  docker run -d --name mq-smoke-redis -p 6379:6379 redis:7-alpine >/dev/null 2>&1 || { fail redis "启动失败"; return; }
  trap 'docker rm -f mq-smoke-redis >/dev/null 2>&1' RETURN
  sleep 2
  say "[redis 2/3] XADD/XREAD 往返..."
  docker exec mq-smoke-redis redis-cli XADD smoke '*' field "smoke-$(date +%s)" >/dev/null 2>&1
  local got
  got=$(docker exec mq-smoke-redis redis-cli XREAD COUNT 1 STREAMS smoke 0 2>/dev/null | grep -c field)
  if [ "${got:-0}" -ge 1 ]; then pass redis; else fail redis "XREAD 无数据"; fi
  say "[redis 3/3] 清理..."; docker rm -f mq-smoke-redis >/dev/null 2>&1; trap - RETURN
}

# ---------- MQTT ----------
smoke_mqtt() {
  port_free 1883 || { skip mqtt "端口 1883 被占用"; return; }
  have_cli mosquitto_sub || { skip mqtt "无 mosquitto 客户端"; return; }
  say "[mqtt 1/3] 启动容器..."
  docker run -d --name mq-smoke-mqtt -p 1883:1883 eclipse-mosquitto >/dev/null 2>&1 || { fail mqtt "启动失败"; return; }
  trap 'docker rm -f mq-smoke-mqtt >/dev/null 2>&1; rm -f /tmp/mqtt-sub.out' RETURN
  sleep 2
  say "[mqtt 2/3] pub/sub 往返..."
  local msg="smoke-$(date +%s)"
  mosquitto_sub -h localhost -t smoke/test -C 1 > /tmp/mqtt-sub.out 2>/dev/null &
  local subpid=$!
  sleep 1
  mosquitto_pub -h localhost -t smoke/test -m "$msg" 2>/dev/null
  sleep 3
  kill "$subpid" 2>/dev/null
  if grep -q "$msg" /tmp/mqtt-sub.out 2>/dev/null; then pass mqtt; else fail mqtt "未收到消息"; fi
  rm -f /tmp/mqtt-sub.out
  say "[mqtt 3/3] 清理..."; docker rm -f mq-smoke-mqtt >/dev/null 2>&1; trap - RETURN
}

# ---------- Pulsar ----------
smoke_pulsar() { skip pulsar "config-templates 无 Pulsar compose 模板，按 TEST-02 手工环境执行"; }

case "$SYSTEM" in
  kafka)     smoke_kafka ;;
  nats)      smoke_nats ;;
  rabbitmq)  smoke_rabbitmq ;;
  redis)     smoke_redis ;;
  mqtt)      smoke_mqtt ;;
  pulsar)    smoke_pulsar ;;
  all)       smoke_kafka; smoke_nats; smoke_rabbitmq; smoke_redis ;;
  *)         echo "用法: $0 [kafka|nats|rabbitmq|redis|mqtt|pulsar|all]"; exit 2 ;;
esac

echo "============================="
echo "汇总: PASS=$PASS FAIL=$FAIL SKIP=$SKIP"
if [ "$FAIL" -eq 0 ]; then echo "✅ 冒烟通过"; else echo "❌ 存在失败项"; fi
exit $([ "$FAIL" -gt 0 ] && echo 1 || echo 0)
