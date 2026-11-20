#!/usr/bin/env python3
"""contract-to-asyncapi.py — 场景 DSL contract.yaml → AsyncAPI spec 骨架生成器（P1 路线图批次95 项，批次187 落地）。

能力边界（诚实声明，与 01-43 设计→DSL 转换规则一致）：
  - 可推导：components.messages 全集（payload 一律 $ref 'contract.yaml#/messages/<Name>/fields'，
    与仓内 8 场景既有 spec 的统一形态一致）；info.version 取 contract.version；
    默认通道 <scenario>.events 挂全部 event 型消息（仓内多数场景惯例）。
  - 不可推导（人工/manifest 补全）：servers、channels 具体集合与 transport bindings
    （kafka/rabbitmq/mqtt/pulsar/nats 绑定、分区/副本、通道拓扑）——contract.yaml 只承载
    消息语义，不含 transport 决策。骨架以 x-todo 标注，不伪造 transport 配置。

用法：
  生成骨架（stdout）:
    python3 contract-to-asyncapi.py <contract.yaml> [--title 标题] [--out 文件]
  结构等价校验（对照既有 spec，RC 0/1）:
    python3 contract-to-asyncapi.py <contract.yaml> --verify <existing.yaml>
    C1 既有 spec components.messages 无孤儿（每条消息在 contract 中存在）
    C2 既有 spec 每条组件 payload.$ref 与 contract 派生形态逐字一致
    C3 既有 spec 通道引用的消息全部落在 components.messages 内（无悬挂通道引用）
    C4 生成器消息全集 ⊇ 既有 spec 组件集（剪枝子集=信息性输出，非缺陷）
"""
import argparse
import os
import re
import sys

try:
    import yaml
except ImportError:
    print("YAML_PARSE_FAIL: PyYAML 缺失", file=sys.stderr)
    sys.exit(4)

DEFAULT_SPEC_VERSION = "3.1.0"


def load_yaml(path, label):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)
    except (OSError, yaml.YAMLError) as e:
        print(f"YAML_PARSE_FAIL: {label} {path}: {e}", file=sys.stderr)
        sys.exit(1)


def derive_payload_ref(name):
    return f"contract.yaml#/messages/{name}/fields"


def camel_from_scenario(scenario):
    return "".join(p.capitalize() for p in re.split(r"[-_]+", scenario) if p)


def build_skeleton(contract, title):
    scenario = contract["scenario"]
    version = str(contract.get("version", "1.0.0"))
    msgs = contract.get("messages") or {}
    events = [n for n, m in msgs.items() if (m or {}).get("type") == "event"]
    title = title or f"{scenario} 契约"
    chan = f"{scenario}.events"
    op_prefix = camel_from_scenario(scenario)

    lines = []
    lines.append(f"# {title} AsyncAPI spec（contract-to-asyncapi.py 生成的骨架）")
    lines.append("# components.messages 派生自 contract.yaml；servers/通道集合/transport bindings 不可从契约推导，")
    lines.append("# 由 x-todo 标注，人工按目标系统补全（见 odcs-alignment.md §三 与 01-43 转换规则）。")
    lines.append(f"asyncapi: '{DEFAULT_SPEC_VERSION}'")
    lines.append("info:")
    lines.append(f"  title: {title}")
    lines.append(f"  version: {version}")
    lines.append(f"  description: {scenario} 域契约 spec（骨架，payload 派生自 contract.yaml）")
    lines.append("channels:")
    lines.append(f"  {chan}:")
    lines.append(f"    address: {chan}")
    lines.append("    messages:")
    for n in events:
        lines.append(f"      {n}: {{ $ref: '#/components/messages/{n}' }}")
    lines.append("    x-todo: 通道集合与 transport binding 不可从契约推导，按目标系统补全（kafka/rabbitmq/mqtt/pulsar/nats）")
    lines.append("operations:")
    lines.append(f"  on{op_prefix}:")
    lines.append("    action: receive")
    lines.append(f"    channel: {{ $ref: '#/channels/{chan}' }}")
    lines.append(f"  publish{op_prefix}:")
    lines.append("    action: send")
    lines.append(f"    channel: {{ $ref: '#/channels/{chan}' }}")
    lines.append("components:")
    lines.append("  messages:")
    for n in msgs:
        lines.append(f"    {n}:")
        lines.append(f"      payload: {{ $ref: '{derive_payload_ref(n)}' }}")
    return "\n".join(lines) + "\n"


def verify(contract, existing):
    errs = []
    info = []
    cmsgs = contract.get("messages") or {}
    amsgs = (existing.get("components") or {}).get("messages") or {}

    # C1 孤儿检查
    orphans = sorted(set(amsgs) - set(cmsgs))
    if orphans:
        errs.append(f"C1 孤儿组件（spec 有而 contract 无）: {orphans}")

    # C2 payload $ref 形态逐字一致
    for name, comp in amsgs.items():
        payload = (comp or {}).get("payload") or {}
        ref = payload.get("$ref")
        expect = derive_payload_ref(name)
        if ref != expect:
            errs.append(f"C2 payload.$ref 形态不符: {name} 实={ref!r} 期={expect!r}")

    # C3 通道引用悬挂
    chan_refs = set()
    for ch in (existing.get("channels") or {}).values():
        chan_refs |= set((ch or {}).get("messages") or {})
    dangling = sorted(chan_refs - set(amsgs))
    if dangling:
        errs.append(f"C3 通道引用悬挂（引用了 components.messages 之外的消息）: {dangling}")

    # C4 生成全集 ⊇ 既有组件集
    pruned = sorted(set(cmsgs) - set(amsgs))
    if pruned:
        info.append(f"C4 信息性: 既有 spec 剪枝未收录 {len(pruned)} 条契约消息（transport 精选子集属设计决策）: {pruned}")

    if errs:
        for e in errs:
            print(f"FAIL {e}")
        return 1
    for i in info:
        print(i)
    print(f"VERIFY_OK components={len(amsgs)} contract_msgs={len(cmsgs)}")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("contract", help="contract.yaml 路径")
    ap.add_argument("--title", help="spec info.title（默认取 scenario 名）")
    ap.add_argument("--out", help="骨架输出文件（默认 stdout）")
    ap.add_argument("--verify", metavar="EXISTING_YAML", help="对照既有 asyncapi.yaml 做结构等价校验（RC 0/1）")
    a = ap.parse_args()

    contract = load_yaml(a.contract, "contract")
    if "scenario" not in contract or "messages" not in contract:
        print("SCHEMA_FAIL: contract.yaml 缺 scenario/messages 必填段", file=sys.stderr)
        sys.exit(1)

    if a.verify:
        existing = load_yaml(a.verify, "existing spec")
        sys.exit(verify(contract, existing))

    text = build_skeleton(contract, a.title)
    if a.out:
        with open(a.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        print(f"GENERATED {a.out} ({len(text)} bytes)")
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
