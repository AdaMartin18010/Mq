#!/usr/bin/env python3
# 文档内嵌代码块巡检（批次198，E0 第十四步）
# 检查项：① 语言标注真实性——开场 fence 标注必须在白名单（仓内现行 33 种，新增须显式入表）
#        ② 裸开场 fence（无标注）=WARN 计数登记（输出块惯例，不阻断）
#        ③ bash 块语法——排除占位符/非 bash CLI/伪代码/JAAS 片段后逐块 bash -n（批次198 实证排除集）
# RC: 0=无 FAIL；1=存在 FAIL（未知标注或 bash 语法错）
import os, re, subprocess, sys, tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)

WHITELIST = {
    "bash", "bnf", "c", "conf", "cpp", "csharp", "dockerfile", "gherkin", "go",
    "hcl", "hocon", "http", "ini", "java", "javascript", "js", "json", "markdown",
    "mermaid", "nginx", "plantuml", "properties", "proto", "protobuf", "python",
    "rust", "scala", "sql", "text", "typescript", "yaml",
}
# bash 语法检查排除面（批次198 实证）：模板占位符 / Redis 与类 CLI 指令 / az·asyncapi / mm2 properties /
# 显式伪代码 / JAAS 配置片段——这些块标 bash 但内容非 bash 语句，语法检查必误报
SKIP_BASH = re.compile(
    r"<[^>]+>|redis-cli|^\s*(XADD|XREADGROUP|XGROUP|XINFO|XRANGE|XSETID)\b"
    r"|az eventhubs|asyncapi\s|伪代码|^\s*clusters\s*=|LoginModule|KafkaClient\s*\{",
    re.M,
)

FENCE = re.compile(r"^```([a-zA-Z0-9_-]*)\s*$", re.M)

def check_text(text):
    fails, bare, bash_ok, bash_skip = [], 0, 0, 0
    lines = text.splitlines()
    opens = []  # (lineno, tag)
    inblock = False
    cur = None
    for i, ln in enumerate(lines, 1):
        mo = FENCE.match(ln)
        if not mo:
            if inblock and cur is not None:
                cur[2].append(ln)
            continue
        tag = mo.group(1)
        if not inblock:
            inblock = True
            cur = [i, tag, []]
        else:
            # closing fence
            ln0, tag, body = cur
            if tag == "":
                bare += 1
            elif tag not in WHITELIST:
                fails.append(f"L{ln0} 未知语言标注: {tag}")
            if tag == "bash":
                src = "\n".join(body)
                if SKIP_BASH.search(src):
                    bash_skip += 1
                else:
                    with tempfile.NamedTemporaryFile("w", suffix=".sh", delete=False, encoding="utf-8") as tf:
                        tf.write(src + "\n"); p = tf.name
                    r = subprocess.run(["bash", "-n", p], capture_output=True)
                    os.unlink(p)
                    if r.returncode != 0:
                        err = r.stderr.decode(errors="replace").strip().splitlines()
                        fails.append(f"L{ln0} bash 语法错: {err[-1][:100] if err else 'unknown'}")
                    else:
                        bash_ok += 1
            inblock = False
            cur = None
    return fails, bare, bash_ok, bash_skip

def selftest():
    bad_tag = "```pythn\nprint(1)\n```\n"
    bad_bash = "```bash\nif true; then\n  echo hi\n```\n"
    clean = "```bash\nif true; then\n  echo hi\nfi\n```\n\n```text\nplain\n```\n"
    f1, _, _, _ = check_text(bad_tag)
    f2, _, _, _ = check_text(bad_bash)
    f3, b3, ok3, _ = check_text(clean)
    ok = (len(f1) == 1 and "pythn" in f1[0] and len(f2) == 1 and "语法错" in f2[0]
          and not f3 and ok3 == 1 and b3 == 0)
    print(f"SELFTEST bad_tag={'OK' if len(f1)==1 else 'FAIL'} bad_bash={'OK' if len(f2)==1 else 'FAIL'} clean={'OK' if not f3 and ok3==1 else 'FAIL'}"
          f" [debug f1={f1} f2={f2} f3={f3} b3={b3} ok3={ok3}]")
    return 0 if ok else 1

if "--selftest" in sys.argv:
    sys.exit(selftest())

files = subprocess.run(["git", "ls-files", "*.md"], capture_output=True, text=True).stdout.split()
all_fails, tot_bare, tot_ok, tot_skip, nfiles = [], 0, 0, 0, 0
for f in files:
    try:
        t = open(f, encoding="utf-8").read()
    except (UnicodeDecodeError, OSError):
        continue
    nfiles += 1
    fails, bare, ok, skip = check_text(t)
    tot_bare += bare; tot_ok += ok; tot_skip += skip
    for x in fails:
        all_fails.append(f"{f}: {x}")

print(f"CODEBLOCK_CHECK files={nfiles} tags_bash_ok={tot_ok} bash_skip={tot_skip} bare_warn={tot_bare}")
if all_fails:
    print(f"FAILS={len(all_fails)}")
    for x in all_fails[:15]:
        print("  " + x)
    sys.exit(1)
print("PASS: 语言标注白名单+ bash 块语法全绿")
sys.exit(0)
