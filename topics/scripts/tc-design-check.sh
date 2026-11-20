#!/usr/bin/env bash
# tc-design-check.sh — TC-DESIGN 用例族三向一致性巡检（批次181）
# 规则源：topics/01-基础概念与对比分析/01-89-构件设计论证模板.md §1.89.2 预映射表
#   「典型否决案例」列=负面用例种子 → 每行一个 TC-DESIGN-* 用例（§1.89.5 接口约定）
# 三向对象：
#   A=§1.89.2 表数据行（种子数）
#   B=topics/scripts/test-registry.tsv 中 TC-DESIGN-* 行（注册数）
#   C=Testing/07-集成矩阵/design-review/**/TC-DESIGN-*.md（case 文件数）
# 判定（全过 RC=0，任一失败 RC=1）：
#   C1 B↔C 一一对应（注册 ID 集合 == 文件 stem 集合）
#   C2 A==B（每行否决案例种子恰有一个注册用例，不多不少）
#   C3 每个 case 文件结构完整（Given/When/Then 三节）
#   C4 每个注册行 doc_refs 含规则源 01-89
#   C5 每个 case 文件首行标题含自身 ID
# 用法：bash topics/scripts/tc-design-check.sh [repo_root]

set -u
# MSYS 下 pwd/dirname 产 /e/... 风格路径，python/node 等原生程序须 cygpath -m 归一（陷阱#12）
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REPO_ROOT="$(cygpath -m "$REPO_ROOT")"
[ "${1:-}" != "" ] && REPO_ROOT="$(cygpath -m "$1")"
TPL="$REPO_ROOT/topics/01-基础概念与对比分析/01-89-构件设计论证模板.md"
REG="$REPO_ROOT/topics/scripts/test-registry.tsv"
DREV="$REPO_ROOT/Testing/07-集成矩阵/design-review"

if [ ! -f "$TPL" ] || [ ! -f "$REG" ] || [ ! -d "$DREV" ]; then
  echo "ERROR: 输入缺失 tpl/reg/dreview"
  exit 1
fi

python3 - "$TPL" "$REG" "$DREV" <<'PYEOF'
import sys, os, re

tpl, reg, drev = sys.argv[1], sys.argv[2], sys.argv[3]
fails = []

# A: 解析 §1.89.2 表数据行（跳过表头行与分隔行）
rows = []
in_sec = False
for line in open(tpl, encoding="utf-8"):
    if line.startswith("## 1.89.2"):
        in_sec = True
        continue
    if in_sec and line.startswith("## "):
        break
    if in_sec and line.strip().startswith("|"):
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if not cells or cells[0] in ("构件声明",) or set(cells[0]) <= set("-: "):
            continue
        rows.append(cells)
A = len(rows)

# B: 注册表 TC-DESIGN 行
ids, refs_ok = [], []
for line in open(reg, encoding="utf-8"):
    if line.startswith("#") or not line.strip():
        continue
    parts = line.rstrip("\n").split("\t")
    if len(parts) >= 6 and parts[0].startswith("TC-DESIGN-"):
        ids.append(parts[0])
        refs_ok.append("01-89" in parts[4])
B = len(ids)
dup = len(ids) != len(set(ids))

# C: case 文件 stems
stems = sorted(
    os.path.splitext(f)[0]
    for d, _, fs in os.walk(drev)
    for f in fs
    if f.startswith("TC-DESIGN-") and f.endswith(".md")
)
C = len(stems)

# C1 一一对应
only_reg = sorted(set(ids) - set(stems))
only_file = sorted(set(stems) - set(ids))
if only_reg or only_file or dup:
    fails.append(f"C1 B<->C 不对应: 仅注册={only_reg} 仅文件={only_file} 重复ID={dup}")

# C2 种子数==注册数
if A != B:
    fails.append(f"C2 种子数 A={A} != 注册数 B={B}")

# C3 结构完整
bad_struct = []
for s in stems:
    for d, _, fs in os.walk(drev):
        if s + ".md" in fs:
            t = open(os.path.join(d, s + ".md"), encoding="utf-8").read()
            if not all(h in t for h in ("## Given", "## When", "## Then")):
                bad_struct.append(s)
            break
if bad_struct:
    fails.append(f"C3 结构缺节: {bad_struct}")

# C4 规则源声明
if not all(refs_ok):
    fails.append("C4 存在 doc_refs 不含 01-89 的注册行")

# C5 标题含自身 ID
bad_title = []
for s in stems:
    for d, _, fs in os.walk(drev):
        if s + ".md" in fs:
            first = open(os.path.join(d, s + ".md"), encoding="utf-8").readline()
            if s not in first:
                bad_title.append(s)
            break
if bad_title:
    fails.append(f"C5 标题缺 ID: {bad_title}")

print(f"CHECKS: 种子行A={A} 注册B={B} 文件C={C}")
if fails:
    for f in fails:
        print(f"FAIL: {f}")
    sys.exit(1)
print("CHECKS: PASS (C1 一一对应 / C2 种子=注册 / C3 结构 / C4 规则源 / C5 标题)")
PYEOF
rc=$?
echo "TC-DESIGN-CHECK-RC=$rc"
exit $rc
