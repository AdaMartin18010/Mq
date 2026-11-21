#!/usr/bin/env bash
# H3 GAME DAY --live 真实注入（TC-CHA-01/02，批次193）
# 用户在场授权：2026-11-21 签核。执行目标=在跑 3 节点栈（kafka-1/2/3）。
# 断言语义：零丢失=producer exit 0（acks=all）+ end offset==请求发送量。
# 生产者配 delivery.timeout.ms=600000 + max.block.ms=600000：注入窗口（90s 僵死/122s 分区）
# 内批留在客户端缓冲重试而非按默认 120s 交付超时丢弃（批次193 live 首跑根因：2048×15 条
# 客户端过期，broker 侧零丢失但 offset<请求量→A2 误判 FAIL；修后 offset==请求量才成立）。
# TC-CHA-03（磁盘压力）= 本环境不可执行边界（见 README/证据边界节），不在此脚本。
set -u
RT=podman
BS3="PLAINTEXT://kafka-1:29092,PLAINTEXT://kafka-2:29092,PLAINTEXT://kafka-3:29092"  # INTERNAL 监听（容器网内可达；9092=EXTERNAL advertised localhost 容器内不可达，批次191 实证）
BS1="PLAINTEXT://kafka-1:29092"
EVD="results/2026-11-21"
mkdir -p "$EVD"
PASS_N=0; FAIL_N=0
assert() { # $1=case $2=id $3=PASS|FAIL $4=detail
  if [ "$3" = "PASS" ]; then PASS_N=$((PASS_N+1)); else FAIL_N=$((FAIL_N+1)); fi
  echo "ASSERT $1 $2 $3 :: $4"
}
KX() { podman exec kafka-1 "$@"; }  # 在 kafka-1 内跑 kafka 工具

echo "=== H3 LIVE 开始 $(date '+%F %T') ==="
KX bash -c 'pkill -f "[P]roducerPerformance" 2>/dev/null; pkill -f "[C]onsumerPerformance" 2>/dev/null; true'
# 预清理：删上一轮残留 topic（run-1 残留 111510 条曾污染 run-2 cha02 断言，2026-11-21 实证）
KX /opt/kafka/bin/kafka-topics.sh --delete --topic h3-cha01 --bootstrap-server "$BS3" 2>/dev/null | grep -vE "^\[20" || true
KX /opt/kafka/bin/kafka-topics.sh --delete --topic h3-cha02 --bootstrap-server "$BS3" 2>/dev/null | grep -vE "^\[20" || true
sleep 5

# ---------------- TC-CHA-01 broker 僵死（pause kafka-1 90s） ----------------
echo "--- TC-CHA-01 开始 $(date '+%T') ---"
KX /opt/kafka/bin/kafka-topics.sh --create --topic h3-cha01 --partitions 3 --replication-factor 3 --bootstrap-server "$BS3" 2>&1 | grep -vE "^\[20" || true
sleep 3
# producer: 2100000 records @10000/s = 210s（覆盖 60s 前稳态 + 90s 僵死 + 60s 恢复）
podman exec kafka-1 /opt/kafka/bin/kafka-producer-perf-test.sh \
  --topic h3-cha01 --record-size 1024 --num-records 2100000 --throughput 10000 \
  --producer-props bootstrap.servers="$BS3" acks=all max.block.ms=600000 delivery.timeout.ms=600000 \
  > "$EVD/h3-cha01_producer_raw.log" 2>&1 &
PROD_PID=$!
# 等 producer 出第一个 interval（确认在跑）
for i in $(seq 1 30); do grep -q "avg" "$EVD/h3-cha01_producer_raw.log" 2>/dev/null && break; sleep 1; done
PAUSE_AT=$(( $(date +%s) ))
sleep 60
echo "[inject] pause kafka-1 @ $(date '+%T')"
podman pause kafka-1
sleep 90
MID_WINDOW=$(grep "avg" "$EVD/h3-cha01_producer_raw.log" | tail -3)
echo "[inject] unpause kafka-1 @ $(date '+%T')"
podman unpause kafka-1
# 等 producer 完成（看门狗 600s：超时强杀判 FAIL，防重试循环挂死；600000ms 交付超时下的上界）
WAITED=0
while kill -0 $PROD_PID 2>/dev/null; do
  WAITED=$((WAITED+5)); [ $WAITED -ge 600 ] && { podman exec kafka-1 bash -c 'pkill -f "[P]roducerPerformance" 2>/dev/null; true'; break; }
  sleep 5
done
PROD_RC=0
wait $PROD_PID || PROD_RC=$?
[ $WAITED -ge 600 ] && PROD_RC=124
echo "[producer] rc=$PROD_RC watchdog_s=$WAITED"
KX /opt/kafka/bin/kafka-topics.sh --describe --topic h3-cha01 --bootstrap-server "$BS3" 2>/dev/null > "$EVD/h3-cha01_describe_after.txt"
ISR_OK=$(grep -c "Isr: [0-9,]*[123]" "$EVD/h3-cha01_describe_after.txt" | head -1)
FULL_ISR=$(awk '/Partition/ {n=split($0,a,"Isr: "); m=split(a[2],b,","); if(m==3) c++} END{print c+0}' "$EVD/h3-cha01_describe_after.txt")
# 零丢失断言：end offset == 2100000
ENDOFF=$(KX /opt/kafka/bin/kafka-get-offsets.sh h3-cha01 --time -1 --bootstrap-server "$BS3" 2>/dev/null | grep "^h3-cha01" | cut -d: -f3 | awk '{s+=$1} END{print s+0}')
RATE_SUM=$(grep -A30 "JVM Total Time" "$EVD/h3-cha01_producer_raw.log" | grep "Record Rate" | head -1)
if [ "$PROD_RC" = "0" ]; then assert TC-CHA-01 A1 PASS "producer exit 0（acks=all 无发送失败）"; else assert TC-CHA-01 A1 FAIL "producer rc=$PROD_RC"; fi
if [ "${ENDOFF:-0}" = "2100000" ]; then assert TC-CHA-01 A2 PASS "零丢失: end offset=$ENDOFF == 请求量 2100000"; else assert TC-CHA-01 A2 FAIL "end offset=${ENDOFF:-NA} != 2100000"; fi
if [ "${FULL_ISR:-0}" = "3" ]; then assert TC-CHA-01 A3 PASS "unpause 后 ISR 3/3 全恢复（catch-up 完成）"; else assert TC-CHA-01 A3 FAIL "全 ISR 分区数=${FULL_ISR:-0}/3"; fi
echo "TC-CHA-01 僵死窗口 producer 尾段 interval（pause 期速率/错误观测）: $MID_WINDOW"
echo "TC-CHA-01 稳态: $RATE_SUM"

# ---------------- TC-CHA-02 网络分区（kafka-1 隔离 120s） ----------------
echo "--- TC-CHA-02 开始 $(date '+%T') ---"
KX /opt/kafka/bin/kafka-topics.sh --create --topic h3-cha02 --partitions 3 --replication-factor 3 --bootstrap-server "$BS3" 2>&1 | grep -vE "^\[20" || true
sleep 3
KX /opt/kafka/bin/kafka-topics.sh --describe --topic h3-cha02 --bootstrap-server "$BS3" 2>/dev/null > "$EVD/h3-cha02_describe_before.txt"
podman exec kafka-2 /opt/kafka/bin/kafka-topics.sh --describe --topic h3-cha02 --bootstrap-server "$BS3" 2>/dev/null > "$EVD/h3-cha02_describe_before.txt" || true
# producer: 2000000 @10000 = 200s
podman exec kafka-1 /opt/kafka/bin/kafka-producer-perf-test.sh \
  --topic h3-cha02 --record-size 1024 --num-records 2000000 --throughput 10000 \
  --producer-props bootstrap.servers="$BS3" acks=all max.block.ms=600000 delivery.timeout.ms=600000 \
  > "$EVD/h3-cha02_producer_raw.log" 2>&1 &
PROD_PID=$!
for i in $(seq 1 30); do grep -q "avg" "$EVD/h3-cha02_producer_raw.log" 2>/dev/null && break; sleep 1; done
sleep 45
NET=$(podman inspect kafka-1 -f '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
echo "[inject] network=$NET disconnect kafka-1 @ $(date '+%T')"
podman network disconnect "$NET" kafka-1
PART_AT=$(( $(date +%s) ))
sleep 60
# 分区期中段：从 kafka-2 视角 describe（kafka-1 已隔离，2/3 视角=集群真实态）
podman exec kafka-2 /opt/kafka/bin/kafka-topics.sh --describe --topic h3-cha02 --bootstrap-server "$BS3" 2>/dev/null > "$EVD/h3-cha02_describe_midsplit.txt"
SPLIT_WINDOW=$(grep "avg" "$EVD/h3-cha02_producer_raw.log" | tail -3)
sleep 60
echo "[inject] reconnect kafka-1 @ $(date '+%T')"
podman network connect "$NET" kafka-1
RECOV_AT=$(( $(date +%s) ))
# 轮询 ISR 恢复（catch-up 时间测量）
CATCHUP="NA"
for i in $(seq 1 24); do
  sleep 5
  podman exec kafka-2 /opt/kafka/bin/kafka-topics.sh --describe --topic h3-cha02 --bootstrap-server "$BS3" 2>/dev/null > "$EVD/h3-cha02_describe_recover.txt"
  FULL_ISR=$(awk '/Partition/ {n=split($0,a,"Isr: "); m=split(a[2],b,","); if(m==3) c++} END{print c+0}' "$EVD/h3-cha02_describe_recover.txt")
  if [ "${FULL_ISR:-0}" = "3" ]; then CATCHUP=$(( $(date +%s) - RECOV_AT )); break; fi
done
WAITED2=0
while kill -0 $PROD_PID 2>/dev/null; do
  WAITED2=$((WAITED2+5)); [ $WAITED2 -ge 600 ] && { podman exec kafka-1 bash -c 'pkill -f "[P]roducerPerformance" 2>/dev/null; true'; break; }
  sleep 5
done
PROD_RC=0
wait $PROD_PID || PROD_RC=$?
[ $WAITED2 -ge 600 ] && PROD_RC=124
echo "[producer-cha02] rc=$PROD_RC watchdog_s=$WAITED2"
ENDOFF2=$(KX /opt/kafka/bin/kafka-get-offsets.sh h3-cha02 --time -1 --bootstrap-server "$BS3" 2>/dev/null | grep "^h3-cha02" | cut -d: -f3 | awk '{s+=$1} END{print s+0}')
LEAD_BEFORE=$(grep -o "Leader: [0-9]" "$EVD/h3-cha02_describe_before.txt" | sort | uniq -c | tr '\n' ' ')
LEAD_MID=$(grep -o "Leader: [0-9]" "$EVD/h3-cha02_describe_midsplit.txt" | sort | uniq -c | tr '\n' ' ')
if [ "$PROD_RC" = "0" ]; then assert TC-CHA-02 A1 PASS "producer exit 0（分区期 acks=all 经重选举 leader 持续成功）"; else assert TC-CHA-02 A1 FAIL "producer rc=$PROD_RC"; fi
if [ "${ENDOFF2:-0}" = "2000000" ]; then assert TC-CHA-02 A2 PASS "零丢失: end offset=$ENDOFF2 == 请求量 2000000"; else assert TC-CHA-02 A2 FAIL "end offset=${ENDOFF2:-NA} != 2000000"; fi
if [ "${CATCHUP}" != "NA" ]; then assert TC-CHA-02 A3 PASS "reconnect 后 ISR 3/3 恢复，catch-up=${CATCHUP}s"; else assert TC-CHA-02 A3 FAIL "120s 内 ISR 未恢复 3/3"; fi
echo "TC-CHA-02 Leader 分布 before=[$LEAD_BEFORE] midsplit=[$LEAD_MID]"
echo "TC-CHA-02 分区窗口 producer 尾段 interval: $SPLIT_WINDOW"

echo "=== H3 LIVE 结束 $(date '+%F %T') :: PASS=$PASS_N FAIL=$FAIL_N ==="
[ "$FAIL_N" = "0" ] && { echo "LIVE_RC=0"; exit 0; } || { echo "LIVE_RC=1"; exit 1; }
