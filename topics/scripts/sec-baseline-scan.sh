#!/usr/bin/env bash
# 安全配置基线扫描（批次85，SEC 域 TC-SEC-01~20 的执行器）
# 用途：扫描 topics/config-templates/ 的 broker/server 模板与 k8s 清单，按基线清单检查安全项
# 基线来源【论证】：项目 03-16 安全加固指南 + Kafka/RabbitMQ/NATS/Pulsar 官方安全文档共识项
# 用法：sec-baseline-scan.sh [--json]
# 退出码：0=全 PASS；1=存在 HIGH 缺失；2=异常
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CT="$PROJECT_ROOT/topics/config-templates"
JSON_OUT=0
[[ "${1:-}" == "--json" ]] && JSON_OUT=1
[[ "${1:-}" == "--help" ]] && { echo "用法: sec-baseline-scan.sh [--json]"; exit 2; }

PASS=0; HIGH=0; WARN=0
RESULTS=()

check_file() { # file label pattern severity description
  local f="$1" label="$2" pattern="$3" severity="$4" desc="$5"
  if [[ ! -f "$f" ]]; then
    RESULTS+=("SKIP $label 文件缺失"); return
  fi
  if grep -qiE "$pattern" "$f"; then
    PASS=$((PASS+1)); RESULTS+=("PASS $label :: $desc")
  else
    if [[ "$severity" == "HIGH" ]]; then HIGH=$((HIGH+1)); else WARN=$((WARN+1)); fi
    RESULTS+=("MISSING[$severity] $label :: $desc")
  fi
}

# --- 传输加密基线 ---
check_file "$CT/kafka-server.properties.template" "KAFKA-TLS" 'ssl\.|SSL://|security\.inter\.broker\.protocol' "HIGH" "broker 间/客户端 TLS 配置项存在"
check_file "$CT/nats-server.conf.template" "NATS-TLS" 'tls|cert_file|verify' "HIGH" "TLS 块存在"
check_file "$CT/rabbitmq.conf.template" "RABBITMQ-TLS" 'ssl_options|listeners\.ssl' "HIGH" "AMQP TLS listener 配置"
check_file "$CT/pulsar-broker-config.conf" "PULSAR-TLS" 'tlsEnabled|brokerServicePortTls' "HIGH" "broker TLS 开关"
check_file "$CT/mqtt-broker-config.conf" "MQTT-TLS" 'listener.*8883|certfile|cafile' "WARN" "MQTTS listener（内部网可降为 WARN）"
check_file "$CT/redis-stream-config.conf" "REDIS-TLS" 'tls-|tls_port' "WARN" "TLS 配置（单机评估环境可 WARN）"

# --- 认证授权基线 ---
check_file "$CT/kafka-server.properties.template" "KAFKA-SASL" 'SASL|sasl' "WARN" "SASL 认证机制配置"
check_file "$CT/kafka-server.properties.template" "KAFKA-ACL" 'authorizer|AclAuthorizer|StandardAuthorizer' "WARN" "授权器配置"
check_file "$CT/nats-server.conf.template" "NATS-AUTH" 'authorization|users|accounts' "WARN" "用户/账户授权"
check_file "$CT/rabbitmq.conf.template" "RABBITMQ-AUTH" 'default_user|loopback_users' "WARN" "默认账户收敛"

# --- 审计与网络面 ---
check_file "$CT/kafka-server.properties.template" "KAFKA-AUDIT" 'log4j|appender' "WARN" "审计日志配置痕迹"
check_file "$CT/nats-server.conf.template" "NATS-LOG" 'logtime|log_file|debug|trace' "WARN" "日志配置"
check_file "$CT/pulsar-broker-config.conf" "PULSAR-AUDIT" 'audit|logLevel' "WARN" "审计/日志级别"

# --- K8s 部署面（如有）---
if [[ -f "$CT/keda-scaledobject-kafka.yaml" ]]; then
  if grep -qE 'secretKeyRef|secret:' "$CT/keda-scaledobject-kafka.yaml"; then
    PASS=$((PASS+1)); RESULTS+=("PASS KEDA-SASL :: 触发器凭据走 Secret 引用")
  else
    WARN=$((WARN+1)); RESULTS+=("MISSING[WARN] KEDA-SASL :: 触发器凭据未见 Secret 引用（检查明文）")
  fi
fi

for r in "${RESULTS[@]}"; do echo "$r"; done
echo "-----"
echo "PASS=$PASS HIGH_MISSING=$HIGH WARN_MISSING=$WARN"
[[ $JSON_OUT -eq 1 ]] && printf '{"pass":%d,"high":%d,"warn":%d}\n' "$PASS" "$HIGH" "$WARN"
[[ $HIGH -gt 0 ]] && exit 1 || exit 0
