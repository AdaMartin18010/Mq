#!/usr/bin/env python3
"""跨语言金样本投影客户端（Python，批次189）
用法:
  project_emit.py project <in.jsonl> <out.jsonl>  精确字面量投影
  project_emit.py emit    <in.jsonl> <out.jsonl>  默认编码器再序列化（round-trip）

投影契约（5 语言一致，driver 解析后比较，键序无关）:
  每行 {"i": <事件序号>, "f": {<路径>: [<类型>, <值...>]}}
  类型: str/num/bool/null；num 值 = [精确字面量, 语义值字符串]
  容器展开为叶子路径（点号/下标）；空容器 = ["obj","{}"]/["arr","[]"]
"""
import sys, json

def flatten(v, path, out):
    if isinstance(v, tuple) and len(v) == 3 and v[0] == "num":
        lit, sem = v[1], v[2]
        sem_s = str(int(sem)) if isinstance(sem, int) else repr(float(sem))
        out[path] = ["num", lit, sem_s]
    elif isinstance(v, dict):
        if not v:
            if path:
                out[path] = ["obj", "{}"]
            else:
                out[""] = ["obj", "{}"]
            return
        for k, vv in v.items():
            flatten(vv, f"{path}.{k}" if path else k, out)
    elif isinstance(v, list):
        if not v:
            out[path] = ["arr", "[]"]
            return
        for i, vv in enumerate(v):
            flatten(vv, f"{path}[{i}]", out)
    elif isinstance(v, bool):
        out[path] = ["bool", v]
    elif v is None:
        out[path] = ["null", None]
    elif isinstance(v, str):
        out[path] = ["str", v]
    else:
        raise TypeError(f"unexpected type: {type(v)} at {path}")

def project(in_path, out_path):
    with open(in_path, encoding="utf-8") as fi, open(out_path, "w", encoding="utf-8") as fo:
        for i, line in enumerate(fi):
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line, parse_float=lambda s: ("num", s, float(s)),
                              parse_int=lambda s: ("num", s, int(s)))
            f = {}
            flatten(obj, "", f)
            fo.write(json.dumps({"i": i, "f": f}, ensure_ascii=False) + "\n")

def emit(in_path, out_path):
    with open(in_path, encoding="utf-8") as fi, open(out_path, "w", encoding="utf-8") as fo:
        for line in fi:
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            fo.write(json.dumps(obj, ensure_ascii=False) + "\n")

if __name__ == "__main__":
    mode, in_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]
    if mode == "project":
        project(in_path, out_path)
    elif mode == "emit":
        emit(in_path, out_path)
    else:
        print(f"unknown mode: {mode}", file=sys.stderr)
        sys.exit(2)
