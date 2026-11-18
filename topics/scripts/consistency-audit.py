#!/usr/bin/env python3
# consistency-audit.py：全库一致性审计（批次145，治理域资产，只读）
# 维度：目的层/计划层/模型层/脚本层/规范层/元数据层
# 退出码：0=全部一致；1=存在不一致（清单输出）
import os, re, json, subprocess, sys, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
FINDINGS = []

def check(name, ok, detail=""):
    status = "OK " if ok else "DIFF"
    print(f"[{status}] {name}" + (f" :: {detail}" if detail and not ok else ""))
    if not ok:
        FINDINGS.append(f"{name}: {detail}")

def sh(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True)

# ---------- 1. 元数据层：find 实测 vs STATUS 声明 ----------
total = int(sh("find . -type f -not -path './.git/*' -not -path './.vscode/*' | wc -l").stdout.strip())
status = open("topics/PROJECT_STATUS.md", encoding="utf-8").read()
m = re.search(r"\| \*\*总计\*\* \| \*\*(\d+)\*\*", status)
check("元数据.总计", m and int(m.group(1)) == total, f"STATUS={m.group(1) if m else '?'} find={total}")

def cnt(glob_cmd):
    return int(sh(glob_cmd).stdout.strip())
checks = {
    "01系": ("ls topics/01-基础概念与对比分析/*.md | grep -v README | wc -l", r"01系列(\d+)篇"),
    "02系": ("ls topics/02-场景驱动架构设计/*.md | grep -v README | wc -l", r"02系列(\d+)篇"),
    "03系": ("ls topics/03-架构与运维实践/*.md | grep -v README | wc -l", r"03系列(\d+)篇"),
    "04系": ("ls topics/04-动态系统论与演化分析/*.md | grep -v README | wc -l", r"04系列(\d+)篇"),
}
for name, (cmd, pat) in checks.items():
    actual = cnt(cmd)
    mm = re.search(pat, status)
    check(f"元数据.{name}", mm and int(mm.group(1)) == actual, f"STATUS={mm.group(1) if mm else '?'} find={actual}")

# 元文档数
meta_actual = cnt("ls topics/*.md | wc -l")
mm = re.search(r"\| \*\*元文档\*\* \| (\d+) \|", status)
check("元数据.元文档", mm and int(mm.group(1)) == meta_actual, f"STATUS={mm.group(1) if mm else '?'} find={meta_actual}（注：含README口径见明细）")

# Testing 08 用例数
ops_actual = cnt("find Testing/08-运维行为测试/cases -name 'TC-*.md' | wc -l")
mm = re.search(r"\| \*\*运维行为用例\*\* \| (\d+) \|", status)
check("元数据.08用例", mm and int(mm.group(1)) == ops_actual, f"STATUS={mm.group(1) if mm else '?'} find={ops_actual}")

# ---------- 2. 目的层：定位语句对齐 ----------
agents = open("AGENTS.md", encoding="utf-8").read()
readme = open("README.md", encoding="utf-8").read()
charter = open("topics/KB_CHARTER.md", encoding="utf-8").read()
check("目的.AGENTS定位含权威基础设施", "权威" in agents.split("## 1.")[1][:400] if "## 1." in agents else "权威" in agents[:800])
check("目的.README门面", "知识库" in readme or "消息队列" in readme)
check("目的.宪章三重资产", all(k in charter for k in ["论证资产", "测试资产", "决策资产"]))

# ---------- 3. 计划层：CHANGELOG 版本链 ----------
cl = open("topics/CHANGELOG.md", encoding="utf-8").read()
vers = re.findall(r"## \[(\d+\.\d+\.\d+)\]", cl)
check("计划.CHANGELOG版本链>=3.34", "3.34.0" in vers, f"最新={vers[0] if vers else '无'}")
check("计划.版本数合理", len(vers) >= 15, f"共{len(vers)}个版本")

# ROADMAP 勾记批次覆盖
road = open("topics/ROADMAP.md", encoding="utf-8").read()
for b in ["121-123 运维行为测试", "124-126 静态治理", "127 清欠批", "128-131 运维十类分类法", "133-141 契约层", "K6 两轨运行中"]:
    check(f"计划.ROADMAP含[{b}]", b in road)

# ---------- 4. 模型层 ----------
r = sh("python3 topics/scripts/kg-query.py --check")
check("模型.kg完整性", r.returncode == 0, r.stdout.strip()[-80:])
r = sh("python3 topics/scripts/matrix-check.py")
check("模型.matrix双向同步", r.returncode == 0, r.stdout.strip().splitlines()[-1] if r.stdout else "")

# decision-registry 与 evidence 对应
reg_ids = set()
for line in open("topics/scripts/decision-registry.tsv", encoding="utf-8"):
    if not line.startswith("#") and line.strip(): reg_ids.add(line.split("\t")[0])
ev_ok = True
for line in open("topics/scripts/decision-evidence.tsv", encoding="utf-8"):
    if not line.startswith("#") and line.strip():
        did = line.split("\t")[0]
        if did not in reg_ids: ev_ok = False
check("模型.decision-evidence对应registry", ev_ok)

# TEST 编号唯一性（Testing 命名空间）
import glob as g
test_ids = [os.path.basename(p) for p in g.glob("Testing/00-规范与计划/*.md") + g.glob("Testing/05-体系与机制/*.md")]
names = [re.match(r"(TEST-\S+?)-", t).group(1) for t in test_ids if re.match(r"(TEST-\S+?)-", t)]
dup = [k for k, v in collections.Counter(names).items() if v > 1]
check("模型.TEST编号无撞车", not dup, str(dup))

# ---------- 5. 脚本层 ----------
for s in ["hermes-e0-run.sh", "kg-query.py", "matrix-check.py", "contract-spec-check.sh",
          "tc-assert-check.sh", "ops-gen.py", "err-gen.py", "fal-syn-gen.py",
          "pst-clu-gen.py", "scl-alt-gen.py", "matrix-enrich.py", "consistency-audit.py"]:
    check(f"脚本.存在[{s}]", os.path.isfile(f"topics/scripts/{s}") or os.path.isfile(f"Testing/08-运维行为测试/{s}") or os.path.isfile(f"Testing/07-集成矩阵/{s}"))
bash_files = sh("find topics/scripts -name '*.sh'").stdout.split()
bad = []
for f in bash_files:
    if sh(f"bash -n {f}").returncode != 0: bad.append(f)
check("脚本.bash语法全过", not bad, str(bad[:5]))

# E0 依赖链完整性（registry 中 script 非-行）
miss = 0
for line in open("topics/scripts/test-registry.tsv", encoding="utf-8"):
    if line.startswith("#") or not line.strip(): continue
    c = line.rstrip("\r\n").split("\t")
    if len(c) == 6 and c[5] == "mapped" and c[2] not in ("-", ""):
        found = any(os.path.isfile(f"{d}/{s.strip()}")
                    for s in c[2].split(",")
                    for d in ["topics/scripts", "Testing/06-契约语义测试/04-行为用例",
                              "Testing/06-契约语义测试/06-行为验证", "Testing/07-集成矩阵", "Testing/08-运维行为测试"])
        if not found: miss += 1
check("脚本.mapped脚本存在性", miss == 0, f"缺失{miss}")

# ---------- 6. 规范层：K 族交叉引用 ----------
for k in ["KB_CHARTER", "KB_ENDORSEMENT", "KB_REF_AUDIT", "KB_GOVERNANCE", "KB_DIVISION"]:
    check(f"规范.{k}存在", os.path.isfile(f"topics/{k}.md"))
kd = open("topics/KB_DIVISION.md", encoding="utf-8").read()
for ref in ["K1", "K5", "TEST-16", "HERMES-STATE"]:
    check(f"规范.K6引用[{ref}]", ref in kd)

print()
print(f"===== 审计结论: {len(FINDINGS)} 项不一致 =====")
for f in FINDINGS: print(" -", f)
sys.exit(1 if FINDINGS else 0)
