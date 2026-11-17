#!/usr/bin/env bash
# 契约漂移检测（契约语义测试 L1-L3 层，批次71）
# 用途：检测 spec 顶层声明的参数与引用模板的漂移（spec 声明 vs 模板可配参数）
# 判定规则【论证】：
#   bindings: 块内参数  → 绑定语义，归批次72 绑定矩阵管，不判漂移
#   x-* 扩展块内参数    → 已按 01-44 等价转换策略登记，不判漂移
#   其余顶层声明参数    → 必须在映射模板中存在（大小写不敏感子串），否则 PARAM_MISSING
# 用法：contract-drift-check.sh [--format=ids|full] [--spec 文件]
# 退出码：0=无漂移；1=存在漂移；2=异常
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SERIES_DIR="$PROJECT_ROOT/Testing/06-契约语义测试"
FORMAT="full"; ONLY_SPEC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format=*) FORMAT="${1#--format=}"; shift ;;
    --spec) ONLY_SPEC="$2"; shift 2 ;;
    --help) echo "用法: contract-drift-check.sh [--format=ids|full] [--spec 文件]"; exit 2 ;;
    *) echo "未知参数: $1"; exit 2 ;;
  esac
done

command -v python3 >/dev/null 2>&1 || { echo "ERROR: 需要 python3"; exit 2; }

# spec 参数名 -> 期望模板（新增 spec 时在此登记）
SPEC_TEMPLATE_MAP=(
  "asyncapi-kafka-example.yaml|topics/config-templates/kafka-server.properties.template"
  "asyncapi-mqtt-example.yaml|topics/config-templates/mqtt-broker-config.conf"
  "asyncapi-nats-example.yaml|topics/config-templates/nats-server.conf.template"
  "asyncapi-amqp-example.yaml|topics/config-templates/rabbitmq.conf.template"
  "asyncapi-pulsar-example.yaml|topics/config-templates/pulsar-broker-config.conf"
  "asyncapi-redis-example.yaml|topics/config-templates/redis-stream-config.conf"
)

# YAML 感知提取：顶层声明参数（排除 bindings: 与 x-*: 子树），输出每行一个参数名
PY_EXTRACT='
import sys, yaml
def walk(node, path, out):
    if isinstance(node, dict):
        for k, v in node.items():
            if k == "bindings" or str(k).startswith("x-"):
                continue  # 绑定语义/已登记扩展，不判漂移
            walk(v, path + [str(k)], out)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, path + [str(i)], out)
    else:
        if path and not path[-1].startswith("x-"):
            out.add(path[-1])
d = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
out = set()
walk(d, [], out)
for p in sorted(out):
    print(p)
'

collect_specs() {
  if [[ -n "$ONLY_SPEC" ]]; then echo "$ONLY_SPEC"; return; fi
  for f in "$SERIES_DIR"/01-契约规格/specs/*.yaml; do [[ -f "$f" ]] && basename "$f"; done
  echo "asyncapi-kafka-example.yaml"
  echo "asyncapi-mqtt-example.yaml"
}

DRIFT=0
IDS=()
declare -A SEEN
for spec in $(collect_specs | sort -u); do
  template=""
  for pair in "${SPEC_TEMPLATE_MAP[@]}"; do
    [[ "${pair%%|*}" == "$spec" ]] && template="${pair#*|}"
  done
  spath="$SERIES_DIR/01-契约规格/specs/$spec"
  [[ ! -f "$spath" ]] && spath="$PROJECT_ROOT/topics/config-templates/$spec"
  [[ ! -f "$spath" ]] && { echo "SKIP(缺spec): $spec"; continue; }
  if [[ -z "$template" ]]; then
    echo "SKIP(未登记映射): $spec"; continue
  fi
  tpath="$PROJECT_ROOT/$template"
  if [[ ! -f "$tpath" ]]; then
    echo "DRIFT TEMPLATE_MISSING: $spec -> $template 不存在"
    DRIFT=$((DRIFT+1)); IDS+=("$spec"); continue
  fi
  params="$(python3 -c "$PY_EXTRACT" "$spath" 2>/dev/null | tr -d '\r')"
  for w in $params; do
    # 结构性键名白名单（JSON Schema/AsyncAPI 固有键与数组下标，非业务参数）
    case "$w" in
      type|description|format|enum|required|properties|items|\$ref|name|title|version|summary|contentType|payload|headers|parameters|messages|schemas|servers|channels|operations|components|info|address|action|channel|asyncapi|host|protocol|const|default|[0-9]*) continue ;;
    esac
    if ! grep -qiE "(^|[^a-zA-Z.])${w//./\\.}" "$tpath" 2>/dev/null; then
      key="$spec:$w"
      if [[ -z "${SEEN[$key]:-}" ]]; then
        SEEN[$key]=1
        echo "DRIFT PARAM_MISSING: $spec 参数 '$w' 在模板 $template 中无对应可配项"
        DRIFT=$((DRIFT+1)); IDS+=("$spec")
      fi
    fi
  done
done

if [[ "$FORMAT" == "ids" ]]; then
  printf '%s\n' "${IDS[@]:-}" | sort -u | sed '/^$/d'
else
  echo "-----"
  echo "DRIFT=$DRIFT（绑定语义参数不计入；见 02-语义矩阵/ 批次72 绑定矩阵）"
fi
[[ $DRIFT -gt 0 ]] && exit 1 || exit 0
