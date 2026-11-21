#!/usr/bin/env python3
"""跨语言金样本矩阵驱动（批次189）

两相发现:
  相1 参考分歧: 同一原始样本, 5 语言各自 project 后的规范值不一致 → 跨语言解析分歧
      (如 >2^53 奇数大整数在 float64 语义语言中塌缩, 在 int 精确语义语言中保持)
  相2 边 round-trip: 20 条有向边 A→B = B 解析 A 的默认序列化输出, 与 B 直接解析原始样本比较
      分类: precision_loss(值变) / time_offset(时间戳值变) / optionality_collapse(空性丢失)
            encoding_diff(字符串码点变) / type_shift(类型变) / repr_drift(值同字面量不同, 良性)

用法: python3 matrix_driver.py [--quick]
  --quick: 只跑前 2 个 generator（自检用）
RC: 0=矩阵完成（分歧为发现项, 非失败）; 1=基础设施失败（客户端构建/运行/投影不可解析）
"""
import json, os, re, subprocess, sys, datetime

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
GEN_DIR = os.path.join(REPO, "Testing", "fixtures", "generators")
RESULTS = os.path.join(REPO, "results", datetime.date.today().isoformat(), "xlang-matrix")
JACKSON = os.path.join(HERE, "lib", "jackson-core.jar")
JAVA_SRC = os.path.join(HERE, "java", "project_emit.java")
GO_SRC = os.path.join(HERE, "go", "project_emit.go")
RS_DIR = os.path.join(HERE, "rs")

GEN_NAMES = [
    "gen-audit-trail.py", "gen-cdc-sync.py", "gen-inventory.py",
    "gen-iot-telemetry.py", "gen-notification.py", "gen-orders.py",
    "gen-payments.py", "gen-task-queue.py",
]

def log(msg):
    print(msg, flush=True)

# ---------------- 客户端构建 ----------------
def build_go():
    exe = GO_SRC.replace(".go", "")
    r = subprocess.run(["go", "build", "-o", exe, GO_SRC], capture_output=True, text=True, cwd=HERE, timeout=180)
    if r.returncode != 0:
        raise RuntimeError("go build failed: " + r.stderr[:500])
    return exe

def build_java():
    if not os.path.exists(JACKSON):
        raise RuntimeError("jackson-core.jar 缺失: 先运行 Testing/xlang/ensure-lib.sh")
    r = subprocess.run(["javac", "-cp", JACKSON, "-d", os.path.dirname(JAVA_SRC), JAVA_SRC],
                       capture_output=True, text=True, cwd=HERE, timeout=180)
    if r.returncode != 0:
        raise RuntimeError("javac failed: " + r.stderr[:500])

def build_rs():
    exe = os.path.join(RS_DIR, "target", "release", "project_emit")
    if not os.path.exists(exe):
        r = subprocess.run(["cargo", "build", "--release"], capture_output=True, text=True, cwd=RS_DIR, timeout=600)
        if r.returncode != 0:
            raise RuntimeError("cargo build failed: " + (r.stderr or r.stdout)[:500])

def main():
    quick = "--quick" in sys.argv
    gen_names = GEN_NAMES[:2] if quick else GEN_NAMES
    os.makedirs(RESULTS, exist_ok=True)

    log("[build] go...")
    go_exe = build_go()
    log("[build] java...")
    build_java()
    log("[build] rs...")
    build_rs()

    def run_client(lang, mode, in_path, out_path, raw=False):
        if lang == "py":
            cmd = [sys.executable, os.path.join(HERE, "py", "project_emit.py")]
        elif lang == "node":
            cmd = ["node", os.path.join(HERE, "node", "project_emit.js")]
        elif lang == "go":
            cmd = [go_exe]
        elif lang == "java":
            cmd = ["java", "-cp", JACKSON + os.pathsep + os.path.dirname(JAVA_SRC), "project_emit"]
        elif lang == "rs":
            cmd = [os.path.join(RS_DIR, "target", "release", "project_emit")]
        else:
            raise ValueError(lang)
        r = subprocess.run(cmd + [mode, in_path, out_path], capture_output=True, text=True, cwd=HERE, timeout=300)
        if r.returncode != 0:
            raise RuntimeError(f"client {lang} {mode} RC={r.returncode}: {r.stderr[:300]}")
        if raw:
            return out_path
        return load_jsonl(out_path)

    def load_jsonl(path):
        events = {}
        with open(path, encoding="utf-8") as fi:
            for line in fi:
                line = line.strip()
                if not line:
                    continue
                obj = json.loads(line)
                events[obj["i"]] = obj["f"]
        return events

    LANGS = ["py", "node", "go", "java", "rs"]
    work = os.path.join(RESULTS, "work")
    os.makedirs(work, exist_ok=True)
    infra_errors = []
    summary_rows = []
    refdiv_all = []

    def numval(entry):
        lit = entry[1]
        if re.fullmatch(r"-?\d+", lit):
            return ("int", int(lit))
        return ("float", float(lit))

    def val_eq(a, b):
        # 双 int → 精确比较（大整数 7 的差是真实精度损失, 非良性表征差;
        # float() 化比较会把 10^18 vs 10^18+7 的差掩盖掉）
        if a[0] == "int" and b[0] == "int":
            return a[1] == b[1]
        # int vs float / 双 float → float 相等才视为同值（float 为 int 的精确表示时良性）
        return float(a[1]) == float(b[1])

    TS_RE = re.compile(r"(ts|time|deadline|enqueued|created|updated|occurred|received|at$)", re.I)
    def ts_like(path):
        segs = re.split(r"[.\[\]]", path)
        return any(TS_RE.search(s) for s in segs if s)

    for gen in gen_names:
        gname = gen.replace("gen-", "").replace(".py", "")
        gdir = os.path.join(work, gname)
        os.makedirs(gdir, exist_ok=True)
        sample = os.path.join(gdir, "sample.jsonl")
        r = subprocess.run([sys.executable, os.path.join(GEN_DIR, gen)],
                           capture_output=True, text=True, cwd=GEN_DIR, timeout=60)
        if r.returncode != 0:
            infra_errors.append(f"generator {gen}: RC={r.returncode} {r.stderr[:200]}")
            continue
        with open(sample, "w", encoding="utf-8") as fo:
            fo.write(r.stdout)

        # 相1: 参考分歧
        refs = {}
        for L in LANGS:
            try:
                refs[L] = run_client(L, "project", sample, os.path.join(gdir, f"ref_{L}.jsonl"))
            except Exception as e:
                infra_errors.append(f"{gen} ref {L}: {e}")
        all_paths = set()
        for L in refs:
            for f in refs[L].values():
                all_paths.update(f.keys())
        n_events = max(max(refs[L].keys()) + 1 if refs[L] else 0 for L in refs) if refs else 0
        for p in sorted(all_paths):
            # 按事件聚合: 收集每语言规范值集合
            distinct = {}
            lang_vals = {L: set() for L in LANGS}
            for i in range(n_events):
                for L in LANGS:
                    if L not in refs:
                        continue
                    entry = refs[L].get(i, {}).get(p)
                    if entry is None:
                        lang_vals[L].add("__absent__")
                    elif entry[0] == "num":
                        # 比语义 entry[2]（默认解析器的规范值）：entry[1] 是原文字面量,
                        # 所有语言看到相同值, 比它恒等无信息量（JS 塌缩只体现在 entry[2]）
                        sem = str(entry[2]) if len(entry) > 2 else str(entry[1])
                        if re.fullmatch(r"-?\d+", sem):
                            lang_vals[L].add(repr("int") + ":" + str(int(sem)))
                        else:
                            try:
                                lang_vals[L].add(repr("float") + ":" + repr(float(sem)))
                            except ValueError:
                                lang_vals[L].add(repr("str") + ":" + sem)
                    else:
                        lang_vals[L].add(entry[0] + ":" + json.dumps(entry[1], ensure_ascii=False))
            sets = {L: frozenset(lang_vals[L]) for L in LANGS}
            if len(set(sets.values())) > 1:
                # 按规范值核对：每个值须被所有语言持有（int/float 键形态跨型归并,
                # -1 与 -1.0 同键）；任一值在某语言缺失（被替换为不同数值）= 语义分歧,
                # 否则仅形态分歧
                have = {}
                for L in LANGS:
                    for k in sets[L]:
                        if k.startswith("'int':"):
                            v = int(k.split(":", 1)[1])
                        elif k.startswith("'float':"):
                            v = float(k.split(":", 1)[1])
                        else:
                            v = ("str", k)
                        have.setdefault(v, set()).add(L)
                allL = set(LANGS)
                cls = "semantic" if any(langs != allL for langs in have.values()) else "repr"
                detail = {}
                for L in LANGS:
                    sv = sorted(lang_vals[L])
                    detail[L] = sv[:8] + [f"...共{len(sv)}值"] if len(sv) > 8 else sv
                refdiv_all.append([gname, p, n_events, cls, json.dumps(detail, ensure_ascii=False)])

        # 相2: 边 round-trip
        emits = {}
        for A in LANGS:
            try:
                emits[A] = run_client(A, "emit", sample, os.path.join(gdir, f"emit_{A}.jsonl"), raw=True)
            except Exception as e:
                infra_errors.append(f"{gen} emit {A}: {e}")
        for A in LANGS:
            if A not in emits:
                continue
            for B in LANGS:
                if A == B:
                    continue
                edge = f"{A}->{B}"
                try:
                    pAB = run_client(B, "project", os.path.join(gdir, f"emit_{A}.jsonl"),
                                     os.path.join(gdir, f"p_{A}_{B}.jsonl"))
                except Exception as e:
                    infra_errors.append(f"{gen} edge {edge}: {e}")
                    continue
                if B not in refs:
                    continue
                counts = {"precision_loss": 0, "time_offset": 0, "optionality_collapse": 0,
                          "encoding_diff": 0, "type_shift": 0, "repr_drift": 0}
                detail_rows = []
                for i in range(n_events):
                    fb = refs[B].get(i, {})
                    fg = pAB.get(i, {})
                    for p in sorted(set(fb) | set(fg)):
                        r_ = fb.get(p)
                        g_ = fg.get(p)
                        if r_ == g_:
                            continue
                        if (r_ is None) != (g_ is None):
                            cls = "optionality_collapse"
                        elif r_[0] == "num" and g_[0] == "num":
                            if val_eq(numval(r_), numval(g_)):
                                cls = "repr_drift"
                            elif ts_like(p):
                                cls = "time_offset"
                            else:
                                cls = "precision_loss"
                        elif r_[0] == "str" and g_[0] == "str":
                            cls = "encoding_diff"
                        else:
                            cls = "type_shift"
                        counts[cls] += 1
                        detail_rows.append([edge, gname, i, p,
                                            json.dumps(r_, ensure_ascii=False),
                                            json.dumps(g_, ensure_ascii=False), cls])
                n_diffs = sum(counts.values())
                summary_rows.append([edge, gname, n_events, n_diffs,
                                     counts["precision_loss"], counts["time_offset"],
                                     counts["optionality_collapse"], counts["encoding_diff"],
                                     counts["type_shift"], counts["repr_drift"]])
                if detail_rows:
                    with open(os.path.join(gdir, f"diff_{A}_{B}.tsv"), "w", encoding="utf-8") as fo:
                        fo.write("edge\tgenerator\tevent\tpath\tref\tgot\tclass\n")
                        for row in detail_rows:
                            fo.write("\t".join(str(x) for x in row) + "\n")

    # 汇总输出
    with open(os.path.join(RESULTS, "summary.tsv"), "w", encoding="utf-8") as fo:
        fo.write("edge\tgenerator\tn_events\tn_diffs\tprecision_loss\ttime_offset\toptionality_collapse\tencoding_diff\ttype_shift\trepr_drift\n")
        for row in summary_rows:
            fo.write("\t".join(str(x) for x in row) + "\n")
    with open(os.path.join(RESULTS, "refdiv.tsv"), "w", encoding="utf-8") as fo:
        fo.write("generator\tpath\tn_events\tclass\tlang_values\n")
        for row in refdiv_all:
            fo.write("\t".join(str(x) for x in row) + "\n")

    log("")
    log("=== 相1 参考分歧（跨语言解析分歧）===")
    if not refdiv_all:
        log("  无")
    for row in refdiv_all:
        log(f"  {row[0]} {row[1]} ({row[2]} 事件分歧, class={row[3]})")
        try:
            d = json.loads(row[4])
            for L in LANGS:
                if L in d:
                    log(f"    {L}: {d[L]}")
        except Exception:
            pass
    log("")
    log("=== 相2 边 round-trip 差异汇总 ===")
    edges = {}
    for row in summary_rows:
        edges.setdefault(row[0], []).append(row)
    for edge in sorted(edges):
        rows = edges[edge]
        tot = [sum(r[j] for r in rows) for j in (3, 4, 5, 6, 7, 8, 9)]
        log(f"  {edge}: diffs={tot[0]} (precision={tot[1]} time={tot[2]} opt={tot[3]} enc={tot[4]} type={tot[5]} repr={tot[6]})")
    log("")
    if infra_errors:
        log("=== 基础设施错误 ===")
        for e in infra_errors:
            log("  " + str(e))
        log(f"RC=1 (results: {RESULTS})")
        sys.exit(1)
    log(f"矩阵完成: 相1 分歧 {len(refdiv_all)} 项, 相2 差异行 {sum(r[3] for r in summary_rows)} (results: {RESULTS})")
    sys.exit(0)

if __name__ == "__main__":
    main()
