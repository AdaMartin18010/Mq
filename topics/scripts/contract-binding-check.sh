#!/usr/bin/env bash
# 绑定一致性校验（契约语义测试 L3 层，批次72）
# 用途：按 bindings-matrix.md 的机器规则校验 spec 绑定块——
#   ① 绑定键必须在六系统官方索引内；② 字段必须在官方字段集内（四级）；
#   ③ x- 扩展必须在登记簿内（bindings-matrix.md §三）；④ MQTT 语义字段必须在 operation 级
# 用法：contract-binding-check.sh [--spec 文件] [--json]
# 退出码：0=全 PASS；1=存在 VIOLATION；2=异常
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERIES_DIR="$PROJECT_ROOT/契约语义测试"
ONLY_SPEC=""; JSON_OUT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --spec) ONLY_SPEC="$2"; shift 2 ;;
    --json) JSON_OUT=1; shift ;;
    --help) echo "用法: contract-binding-check.sh [--spec 文件] [--json]"; exit 2 ;;
    *) echo "未知参数: $1"; exit 2 ;;
  esac
done
command -v python3 >/dev/null 2>&1 || { echo "ERROR: 需要 python3"; exit 2; }

# 官方字段集（bindings-matrix.md §二，机器镜像；版本见矩阵，变更须同步两文件）
PY_CHECK='
import sys, yaml

# 系统 -> 四级字段白名单（空集=保留空，出现任何字段即违规）
OFFICIAL = {
  "kafka":   {"server": {"schemaRegistryUrl","schemaRegistryVendor","brokerId","brokerVersion","bindingVersion"},
              "channel": {"partitions","partitionKey","replicationFactor","topicConfiguration","bindingVersion"},
              "operation": {"groupId","clientId","bindingVersion"},
              "message": {"key","schemaLookupStrategy","bindingVersion"}},
  "mqtt":    {"server": {"clientId","cleanSession","lastWill","keepAlive","sessionExpiryInterval","maximumPacketSize","bindingVersion"},
              "channel": set(),
              "operation": {"qos","retain","messageExpiryInterval","bindingVersion"},
              "message": {"payloadFormatIndicator","correlationData","responseTopic","contentType","bindingVersion"}},
  "amqp":    {"server": set(),
              "channel": {"is","exchange","queue","bindingVersion"},
              "operation": {"expiration","userId","cc","bcc","priority","deliveryMode","mandatory","replyTo","timestamp","ack","bindingVersion"},
              "message": set()},
  "nats":    {"server": set(), "channel": set(),
              "operation": {"queue","bindingVersion"}, "message": set()},
  "pulsar":  {"server": {"tenant","bindingVersion"},
              "channel": {"namespace","persistence","compaction","geo-replication","retention","ttl","deduplication","bindingVersion"},
              "operation": set(), "message": set()},
  "redis":   {"server": set(), "channel": set(), "operation": set(), "message": set()},
}
KNOWN = set(OFFICIAL) | {"amqp1","http","ws","jms","sns","sqs","stomp","googlepubsub","ibmmq","solace","anypointmq","mqtt5","ros2"}
# 登记簿（bindings-matrix.md §三）
REGISTERED_X = {"x-jetstream","x-prefetch","x-pulsar-subscription","x-redis","x-semantics"}

def keys(d):
    return set(d) if isinstance(d, dict) else set()

def check_bindings(tag, b, level, errs):
    if not isinstance(b, dict):
        return
    for proto, body in b.items():
        if proto not in KNOWN:
            errs.append(f"BINDING_UNKNOWN[{level}]: {proto}（不在官方索引，需确认或 x- 前缀）"); continue
        if proto in REGISTERED_X or str(proto).startswith("x-"):
            continue
        allowed = OFFICIAL.get(proto, {}).get(level, set())
        extra = keys(body) - allowed
        if extra:
            errs.append(f"FIELD_VIOLATION[{level}.{proto}]: {sorted(extra)} 不在官方字段集（bindings-matrix §二）")

d = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
errs = []
for sid, s in (d.get("servers") or {}).items():
    check_bindings(sid, (s or {}).get("bindings"), "server", errs)
for cid, c in (d.get("channels") or {}).items():
    check_bindings(cid, (c or {}).get("bindings"), "channel", errs)
for oid, o in (d.get("operations") or {}).items():
    check_bindings(oid, (o or {}).get("bindings"), "operation", errs)
    xo = {k for k in (o or {}) if str(k).startswith("x-")}
    for x in xo:
        if x not in REGISTERED_X:
            errs.append(f"X_UNREGISTERED[{oid}]: {x} 不在 bindings-matrix §三 登记簿")
# MQTT 语义字段层级纠察（matrix §四 修正项 1）
for cid, c in (d.get("channels") or {}).items():
    b = (c or {}).get("bindings") or {}
    if "mqtt" in b and isinstance(b["mqtt"], dict) and keys(b["mqtt"]):
        errs.append(f"LEVEL_VIOLATION[{cid}]: mqtt channel binding 应为保留空（qos/retain/expiryInterval 属 operation 级，binding 0.2.0）")
print("OK" if not errs else "VIOLATION: " + "; ".join(errs))
'

collect() {
  if [[ -n "$ONLY_SPEC" ]]; then echo "$ONLY_SPEC"; return; fi
  for f in "$SERIES_DIR"/01-契约规格/specs/*.yaml "$SERIES_DIR"/03-业务场景/*/*.yaml; do
    [[ -f "$f" ]] && echo "$f"
  done
  echo "$PROJECT_ROOT/topics/config-templates/asyncapi-kafka-example.yaml"
  echo "$PROJECT_ROOT/topics/config-templates/asyncapi-mqtt-example.yaml"
}

PASS=0; FAIL=0
while IFS= read -r spec; do
  [[ -z "$spec" ]] && continue
  out="$(python3 -c "$PY_CHECK" "$spec" 2>&1)"
  if [[ "$out" == "OK" ]]; then
    PASS=$((PASS+1)); echo "PASS $(basename "$spec")"
  else
    FAIL=$((FAIL+1)); echo "FAIL $(basename "$spec")"; echo "  $out" | tr ';' '\n' | sed 's/^/  /'
  fi
done < <(collect | sort -u)

echo "-----"
echo "SPECS=$((PASS+FAIL)) PASS=$PASS FAIL=$FAIL"
[[ $JSON_OUT -eq 1 ]] && printf '{"pass":%d,"fail":%d}\n' "$PASS" "$FAIL"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
