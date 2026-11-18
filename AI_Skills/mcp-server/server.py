#!/usr/bin/env python3
"""Mq 知识库 MCP Server（MVP）。只读工具层，封装现有校验/查询脚本；传输 stdio。"""
import argparse
import os
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

# 支持 --dry-run 在无 mcp 包时自检；否则提示安装依赖
try:
    from mcp.server.fastmcp import FastMCP
except ImportError as import_err:
    if "--dry-run" not in sys.argv:
        print(f"错误：mcp 包未安装，请 pip install -r requirements.txt ({import_err})", file=sys.stderr)
        sys.exit(1)
    class FastMCP:
        def __init__(self, name: str):
            self.name = name
            self.tools: list[tuple[str, str]] = []
            self.resources: list[tuple[str, str]] = []
        def tool(self, description: str | None = None):
            def deco(func):
                self.tools.append((func.__name__, description or func.__doc__ or ""))
                return func
            return deco
        def resource(self, uri: str, description: str | None = None):
            def deco(func):
                self.resources.append((uri, description or func.__doc__ or ""))
                return func
            return deco
        def run(self, transport: str = "stdio") -> None:
            raise RuntimeError("dry-run 模式下不会调用 run()")

mcp = FastMCP("mq-knowledge-mcp-server")
ROOT = Path(__file__).resolve().parent.parent.parent
_TOOL_REGISTRY: list[tuple[str, str]] = []
_RES_REGISTRY: list[tuple[str, str]] = []

def _tool(description: str | None = None):
    def deco(func):
        mcp.tool(description=description)(func)
        _TOOL_REGISTRY.append((func.__name__, description or func.__doc__ or ""))
        return func
    return deco

def _resource(uri: str, description: str | None = None):
    def deco(func):
        mcp.resource(uri=uri, description=description)(func)
        _RES_REGISTRY.append((uri, description or func.__doc__ or ""))
        return func
    return deco

def _script(name: str) -> Path:
    return ROOT / "topics" / "scripts" / name

def _tail(text: str, max_len: int) -> str:
    return text if len(text) <= max_len else "…(截断)\n" + text[-max_len:]

def _run(cmd: list[str], timeout: int = 300) -> dict:
    try:
        r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired as e:
        return {"ok": False, "error": f"执行超时（{timeout}s）", "exit_code": -2, "stdout": _tail(e.stdout or "", 2000)}
    except Exception as e:
        return {"ok": False, "error": str(e), "exit_code": -3, "stdout": ""}
    out = {"ok": r.returncode == 0, "exit_code": r.returncode, "stdout": _tail(r.stdout, 4000), "stderr": _tail(r.stderr, 2000)}
    if r.returncode != 0:
        out["error"] = "脚本返回非零退出码"
    return out

def _py(args: list[str]) -> dict:
    sp = _script("kg-query.py")
    if not sp.exists():
        return {"ok": False, "error": "脚本缺失: kg-query.py", "exit_code": -1}
    return _run([sys.executable or "python3", str(sp)] + args)

def _safe(value: str) -> bool:
    return bool(value) and ".." not in value and "/" not in value and os.sep not in value and not value.startswith(("/", "\\"))

# ---------- Tools（全部只读；永不暴露修复/执行类脚本） ----------

@_tool(description="知识库规范自检（doc-self-check.sh）。只读；mode 可选 quick / full / --skill-drift。")
def run_doc_check(mode: str = "quick") -> dict:
    if mode not in {"quick", "full", "--skill-drift"}:
        return {"ok": False, "error": "mode 仅允许 quick / full / --skill-drift", "exit_code": -1}
    sp = _script("doc-self-check.sh")
    return {"ok": False, "error": "脚本缺失: doc-self-check.sh", "exit_code": -1} if not sp.exists() else _run(["bash", str(sp), mode])

@_tool(description="AsyncAPI 契约 spec 静态校验（contract-spec-check.sh）。只读；支持 --json / --dir 路径。")
def run_contract_check(json: bool = False, dir: str = "") -> dict:
    sp = _script("contract-spec-check.sh")
    if not sp.exists():
        return {"ok": False, "error": "脚本缺失: contract-spec-check.sh", "exit_code": -1}
    args: list[str] = ["--json"] if json else []
    if dir:
        if not str((ROOT / dir).resolve()).startswith(str(ROOT)):
            return {"ok": False, "error": "--dir 必须位于项目根目录下", "exit_code": -1}
        args += ["--dir", dir]
    return _run(["bash", str(sp)] + args)

@_tool(description="绑定层一致性校验（contract-binding-check.sh）。只读；支持 --json / --spec 文件路径。")
def run_binding_check(json: bool = False, spec: str = "") -> dict:
    sp = _script("contract-binding-check.sh")
    if not sp.exists():
        return {"ok": False, "error": "脚本缺失: contract-binding-check.sh", "exit_code": -1}
    args: list[str] = ["--json"] if json else []
    if spec:
        target = (ROOT / spec).resolve()
        if not target.is_file() or target.suffix not in {".yaml", ".yml"}:
            return {"ok": False, "error": "--spec 必须是项目内的 yaml 文件", "exit_code": -1}
        args += ["--spec", str(target)]
    return _run(["bash", str(sp)] + args)

@_tool(description="TC-BUS 父用例断言静态校验（tc-assert-check.sh）。只读；支持 --json。")
def run_tc_assert(json: bool = False) -> dict:
    sp = _script("tc-assert-check.sh")
    return {"ok": False, "error": "脚本缺失: tc-assert-check.sh", "exit_code": -1} if not sp.exists() else _run(["bash", str(sp)] + (["--json"] if json else []))

@_tool(description="安全配置基线扫描（sec-baseline-scan.sh）。只读；支持 --json。")
def run_sec_scan(json: bool = False) -> dict:
    sp = _script("sec-baseline-scan.sh")
    return {"ok": False, "error": "脚本缺失: sec-baseline-scan.sh", "exit_code": -1} if not sp.exists() else _run(["bash", str(sp)] + (["--json"] if json else []))

@_tool(description="概念卡查询（kg-query.py --concept）。返回概念定义、出边/入边关系。")
def concept_lookup(name: str) -> dict:
    return {"ok": False, "error": "概念名非法或为空", "exit_code": -1} if not _safe(name) else _py(["--concept", name])

@_tool(description="场景×系统适配判定（kg-query.py --judge --explain）。返回 SUPPORTED / MISSING / CONFLICT 结论。")
def kg_judge(scenario: str, system: str) -> dict:
    if not _safe(scenario) or not _safe(system):
        return {"ok": False, "error": "scenario 或 system 名称非法", "exit_code": -1}
    return _py(["--judge", "--scenario", scenario, "--system", system, "--explain"])

# ---------- Resources（只读文档片段） ----------

@_resource("mq://concepts/{name}", description="知识图谱概念卡（kg-query.py --concept）。")
def concept_resource(name: str) -> str:
    sp = _script("kg-query.py")
    if not sp.exists():
        return "错误：kg-query.py 脚本缺失"
    r = subprocess.run([sys.executable or "python3", str(sp), "--concept", unquote(name)], cwd=ROOT, capture_output=True, text=True, timeout=60)
    return r.stdout if r.returncode == 0 else f"查询失败（exit={r.returncode}）：{r.stderr or r.stdout}"

@_resource("mq://docs/{path}", description="只读文档片段。path 仅允许 topics/ / Testing/ / concept/ 下的 .md 文件。")
def doc_resource(path: str) -> str:
    raw = unquote(path).lstrip("/").replace("\\", "/")
    if not raw or ".." in raw.split("/"):
        return "错误：非法路径（禁止目录穿越）"
    target = (ROOT / raw).resolve()
    allowed = [ROOT / p for p in ("topics", "Testing", "concept")]
    if not any(str(target).startswith(str(a) + os.sep) for a in allowed) or target.suffix.lower() != ".md":
        return "错误：仅允许 topics/、Testing/、concept/ 下的 .md 文件"
    if not target.exists():
        return f"错误：文档不存在 {target.relative_to(ROOT)}"
    try:
        return target.read_text(encoding="utf-8")
    except Exception as e:
        return f"读取失败：{e}"

# ---------- 入口 ----------



# ---- 批次136 v2 新增 tools ----
import csv as _csv

_KB_VERSION = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True, cwd=ROOT).stdout.strip() if os.path.isdir(os.path.join(ROOT, ".git")) else "unknown"

def _tsv_lookup(path, key_col, query):
    hits = []
    with open(os.path.join(ROOT, path), encoding="utf-8") as f:
        for line in f:
            if line.startswith("#") or not line.strip(): continue
            cols = line.rstrip(chr(13) + chr(10)).split(chr(9))
            if query.lower() in cols[key_col].lower():
                hits.append(cols)
    return hits

@mcp.tool()
def decision_lookup(query: str) -> dict:
    """决策判定检索：按关键词命中 decision-registry 判定与溯源（K1 §2 P1-P2 引用入口）。
    返回 kb_version 与 kb_refs 引用三元组（KB_REF_AUDIT §1）。"""
    reg = _tsv_lookup("topics/scripts/decision-registry.tsv", 0, query)
    ev = _tsv_lookup("topics/scripts/decision-evidence.tsv", 0, query)
    return {"ok": True, "kb_version": _KB_VERSION,
            "decisions": reg[:5], "evidence": ev[:3],
            "kb_refs": [{"doc": "topics/scripts/decision-registry.tsv", "commit": _KB_VERSION, "confidence": "按条目 degree"}]}

@mcp.tool()
def case_lookup(query: str) -> dict:
    """案例/用例检索：verified 用例与故障案例（agent 可信断言清单入口）。"""
    reg = _tsv_lookup("topics/scripts/test-registry.tsv", 0, query)
    verified = [r for r in reg if r[5] == "verified"]
    return {"ok": True, "kb_version": _KB_VERSION, "matched": len(reg), "verified": verified[:5],
            "kb_refs": [{"doc": "topics/scripts/test-registry.tsv", "commit": _KB_VERSION}]}

@mcp.tool()
def knowledge_version() -> dict:
    """知识版本查询：当前库 commit、时效等级表入口、宪章版本。"""
    return {"ok": True, "kb_version": _KB_VERSION, "charter": "kb_charter v1.0",
            "charter_docs": ["topics/KB_CHARTER.md", "topics/KB_ENDORSEMENT.md", "topics/KB_REF_AUDIT.md", "topics/KB_GOVERNANCE.md"]}


_TOOL_REGISTRY += [
    ("decision_lookup", "决策判定检索：registry 命中+溯源+kb_refs（K1 §2 P1-P2 入口）"),
    ("case_lookup", "用例/案例检索：verified 清单=agent 可信断言清单"),
    ("knowledge_version", "知识版本查询：commit+宪章版本+时效等级入口"),
]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Mq 知识库 MCP Server")
    parser.add_argument("--dry-run", action="store_true", help="无依赖打印将注册的 tools/resources 清单")
    args = parser.parse_args()
    if args.dry_run:
        print(f"# MCP server dry-run: {mcp.name}\n# 以下工具/资源将在 stdio 传输下注册：")
        for name, desc in _TOOL_REGISTRY:
            print(f"TOOL {name}: {desc}")
        for uri, desc in _RES_REGISTRY:
            print(f"RESOURCE {uri}: {desc}")
        sys.exit(0)
    mcp.run(transport="stdio")
