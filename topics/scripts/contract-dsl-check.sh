#!/usr/bin/env bash
# 场景 DSL 契约静态校验（契约语义测试 L1 层）
# 用途：用 Testing/06-契约语义测试/01-契约规格/dsl-schema.json 校验所有 contract.yaml
# 用法：contract-dsl-check.sh [--json]
# 退出码：0=全 PASS；1=存在 FAIL；2=依赖缺失
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEMA="$PROJECT_ROOT/Testing/06-契约语义测试/01-契约规格/dsl-schema.json"
JSON_OUT=0

[[ "${1:-}" == "--json" ]] && JSON_OUT=1

command -v python3 >/dev/null 2>&1 || { echo "ERROR: 需要 python3"; exit 2; }
[[ -f "$SCHEMA" ]] || { echo "ERROR: 缺失 schema $SCHEMA"; exit 2; }

PY_CHECK='
import sys, json, yaml
from jsonschema import validate, ValidationError
schema = json.load(open(sys.argv[1], encoding="utf-8"))
rc = 0
for f in sys.argv[2:]:
    try:
        doc = yaml.safe_load(open(f, encoding="utf-8"))
        validate(doc, schema)
        print(f"VALID {f}")
    except ValidationError as e:
        print(f"INVALID {f}: {e.message} (path={list(e.path)})")
        rc = 1
    except Exception as e:
        print(f"ERROR {f}: {e}")
        rc = 1
sys.exit(rc)
'

python3 -c "import jsonschema" 2>/dev/null || { echo "ERROR: 需要 python3-jsonschema"; exit 2; }

FILES=("$PROJECT_ROOT"/Testing/06-契约语义测试/03-业务场景/*/contract.yaml)
out="$(python3 -c "$PY_CHECK" "$SCHEMA" "${FILES[@]}" 2>&1)"
rc=$?

PASS=$(echo "$out" | grep -c '^VALID ')
FAIL=$(echo "$out" | grep -c '^INVALID ')
ERR=$(echo "$out" | grep -c '^ERROR ')

echo "$out"
echo "-----"
echo "SCHEMA=$SCHEMA PASS=$PASS FAIL=$FAIL ERROR=$ERR"
[[ $JSON_OUT -eq 1 ]] && printf '{"pass":%d,"fail":%d,"error":%d}\n' "$PASS" "$FAIL" "$ERR"
[[ $rc -ne 0 ]] && exit 1 || exit 0
