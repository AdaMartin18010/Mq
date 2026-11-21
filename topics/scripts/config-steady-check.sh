#!/usr/bin/env bash
# 动态验证②：配置稳态巡检（批次196）——compose 模板漂移检查
# 规则：① 禁 version: 顶层废弃行（批次167 清理成果防回潮）② kafka compose 必带 healthcheck（批次175 教训）
#      ③ :latest 镜像=WAR 清单（nats:latest=批次174 实证例外；confluent cp-*:latest=ZK 时代遗留漂移，登记待清）
# RC: 0=无 FAIL（WARN 不阻断）；1=存在 FAIL
set -u
cd "$(cd "$(dirname "$0")/../.." && pwd)" || exit 1
fail=0; warn=0

for f in topics/config-templates/docker-compose-*.yml; do
  n="$(basename "$f")"
  grep -qE "^version:" "$f" && { echo "FAIL: $n 存在废弃 version: 顶层行"; fail=1; }
  if [[ "$n" == *kafka* ]]; then
    hc="$(grep -c "healthcheck:" "$f")"
    [ "$hc" -ge 1 ] || { echo "FAIL: $n 缺 healthcheck（kafka 多节点须 INTERNAL 引导健康检查）"; fail=1; }
  fi
  while read -r img; do
    case "$img" in
      nats:latest) ;;
      confluentinc/cp-zookeeper:latest|confluentinc/cp-kafka:latest)
        echo "WARN: $n 用 $img（ZK 时代遗留，kafka 模板已 KRaft 化=批次167，待清漂移）"; warn=$((warn+1)) ;;
      *:latest)
        echo "WARN: $n 用 $img（:latest 未钉版本）"; warn=$((warn+1)) ;;
    esac
  done < <(grep -oE "image: [^ ]+" "$f" | awk '{print $2}')
done

echo "STEADY_CHECK fail=$fail warn=$warn"
if [ "$fail" -eq 0 ]; then
  echo "PASS: 配置稳态巡检（WARN=$warn 登记不阻断）"
  exit 0
fi
echo "FAIL: 配置稳态巡检"
exit 1
