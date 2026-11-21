#!/usr/bin/env bash
# 拉取 jackson-core（版本 + SHA256 双钉定，批次189）
# jackson-core 仅用于 Java 投影客户端的流式解析/再序列化；缺失时自动从 Maven Central 拉取。
set -euo pipefail
cd "$(dirname "$0")"
JAR=lib/jackson-core.jar
VER=2.18.2
URL="https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${VER}/jackson-core-${VER}.jar"
PIN=lib/jackson-core.sha256
mkdir -p lib
if [ ! -f "$JAR" ]; then
  echo "[ensure-lib] 拉取 $URL"
  curl -fsSL --retry 3 -o "$JAR" "$URL"
fi
if [ -f "$PIN" ] && [ -s "$PIN" ]; then
  actual=$(sha256sum "$JAR" | awk '{print $1}')
  expected=$(awk '{print $1}' "$PIN")
  if [ "$actual" != "$expected" ]; then
    echo "[ensure-lib] SHA256 不符: $actual != $expected" >&2
    exit 1
  fi
  echo "[ensure-lib] SHA256 已验证: $actual"
else
  sha256sum "$JAR" | awk '{print $1}' > "$PIN"
  echo "[ensure-lib] 已记录 SHA256: $(cat "$PIN")"
fi
echo "[ensure-lib] OK: $JAR"
