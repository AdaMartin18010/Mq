#!/usr/bin/env python3
# contract.yaml -> ODCS v3.1.0 导出器（契约语义测试批次79）
# 用法: contract-to-odcs.py <contract.yaml> [--check]
#   默认：输出 ODCS YAML 到 stdout
#   --check：反向校验 contract 含必备段（scenario/version/messages/invariants），缺段列清单退出 1
# 映射规则见 契约语义测试/00-模型与规划/odcs-alignment.md §二
import sys, yaml

def fail(msg):
    print(f"FAIL: {msg}", file=sys.stderr); sys.exit(1)

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    check_only = "--check" in sys.argv
    if not args:
        fail("用法: contract-to-odcs.py <contract.yaml> [--check]")
    src = args[0]
    try:
        c = yaml.safe_load(open(src, encoding="utf-8"))
    except Exception as e:
        fail(f"YAML 解析失败: {e}")

    required = ["scenario", "version", "messages", "invariants"]
    missing = [k for k in required if k not in c]
    if missing:
        print(f"MISSING: {','.join(missing)}")
        if check_only:
            sys.exit(1)

    if check_only:
        print("CHECK_OK")
        return

    props = []
    for mname, m in (c.get("messages") or {}).items():
        for fname, f in ((m or {}).get("fields") or {}).items():
            t = (f or {}).get("type", "string")
            entry = {
                "name": f"{mname}.{fname}",
                "type": {"string": "string", "number": "number", "integer": "integer",
                         "timestamp": "timestamp", "array": "array", "object": "object",
                         "boolean": "boolean"}.get(str(t), "string"),
                "description": (f or {}).get("desc", ""),
                "physicalType": str(t),
            }
            if isinstance(f, dict) and "enum" in f:
                entry["enum"] = f["enum"]
            props.append(entry)

    odcs = {
        "apiVersion": "v3.1.0",
        "kind": "DataContract",
        "id": c["scenario"],
        "name": c["scenario"],
        "version": str(c["version"]),
        "status": "active",
        "schema": [{"name": c["scenario"], "properties": props}],
        "sla": c.get("sla") or {},
        "quality": [
            {"column": q.get("column", ""), "type": q.get("type", ""),
             "severity": q.get("severity", "warning"),
             **({"maximum": q["maximum"]} if "maximum" in q else {})}
            for q in (c.get("quality") or [])
        ],
        "customProperties": {
            "x-semantics-source": "契约语义测试/02-语义矩阵/TEST-14",
            "x-invariants": [str(i) for i in (c.get("invariants") or [])],
            **({"x-stateMachine": c["stateMachine"]} if "stateMachine" in c else {}),
        },
    }
    yaml.safe_dump(odcs, stream=sys.stdout, allow_unicode=True, sort_keys=False)

if __name__ == "__main__":
    main()
