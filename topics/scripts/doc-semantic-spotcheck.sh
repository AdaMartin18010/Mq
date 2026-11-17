#!/bin/bash
# 主题文档语义抽检脚本（批次63 语义抽检机制落地）
# 用法: doc-semantic-spotcheck.sh [--help]
# 抽样规则:
#   - 范围: topics/01~04 系列主题文档（*.md，排除 README）
#   - 确定性: 固定种子 = 当月月份（date +%m），按文件总数步长抽样
#   - 样本量: N=6
# 检查项:
#   1. 置信标注存在性（【定理】/【论证】/【估算】至少其一）
#   2. 时效声明或最后更新日期存在
#   3. 互链段存在（至少 1 个 ./ 或 ../ 相对链接）
#   4. 目录与章节号粗一致性（首个章节号 vs 文件编号前缀，如 01-25 → 1.25）
# 退出码: 0=全部通过；1=存在 FAIL
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCS_DIR="$ROOT/topics"

if [ "${1:-}" = "--help" ]; then
  sed -n '2,/^# 退出码/p' "$0"
  exit 0
fi

SEED=$(date +%m)
N=6

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

find "$DOCS_DIR"/0[1-4]-* -maxdepth 1 -type f -name '*.md' ! -name 'README.md' | \
  sort > "$TMPDIR/all.txt"
TOTAL=$(wc -l < "$TMPDIR/all.txt")

if [ "$TOTAL" -eq 0 ]; then
  echo "[ERROR] 未找到 01~04 系列主题文档"
  exit 1
fi

if [ "$TOTAL" -le "$N" ]; then
  cp "$TMPDIR/all.txt" "$TMPDIR/sample.txt"
else
  STEP=$(( TOTAL / N ))
  [ "$STEP" -lt 1 ] && STEP=1
  START=$(( (SEED % STEP) + 1 ))
  awk -v start="$START" -v step="$STEP" -v n="$N" '
    NR==start || (NR>=start && (NR-start)%step==0) { print; c++; if (c>=n) exit }
  ' "$TMPDIR/all.txt" > "$TMPDIR/sample.txt"
  # 若边界导致不足 N 个，按余数补齐
  GOT=$(wc -l < "$TMPDIR/sample.txt")
  if [ "$GOT" -lt "$N" ]; then
    awk 'NR==FNR{a[$0];next} !($0 in a)' "$TMPDIR/sample.txt" "$TMPDIR/all.txt" > "$TMPDIR/remaining.txt"
    REMAIN=$(wc -l < "$TMPDIR/remaining.txt")
    if [ "$REMAIN" -gt 0 ]; then
      FILL=$(( N - GOT ))
      awk -v seed="$SEED" -v fill="$FILL" '
        BEGIN{ srand(seed) }
        { a[NR]=$0 }
        END{
          while (count<fill && NR>0) {
            idx=int(rand()*NR)+1
            if (idx in a) { print a[idx]; delete a[idx]; count++ }
          }
        }
      ' "$TMPDIR/remaining.txt" >> "$TMPDIR/sample.txt"
    fi
  fi
fi

echo "=== 主题文档语义抽检 (seed=${SEED}, N=${N}, total=${TOTAL}) ==="

PASS=0
FAIL=0
TOTAL_LINES=0

while IFS= read -r f; do
  rel=${f#"$ROOT/"}
  lines=$(wc -l < "$f")
  TOTAL_LINES=$((TOTAL_LINES + lines))

  ok_conf=0
  ok_time=0
  ok_link=0
  ok_chap=0

  # 1. 置信标注
  if grep -qE '【定理】|【论证】|【估算】' "$f"; then
    ok_conf=1
  fi

  # 2. 时效声明或最后更新日期
  if grep -qE '> \*\*时效声明\*\*' "$f" || \
     tail -5 "$f" | grep -qE '\*\*最后更新\*\*: [0-9]{4}-[0-9]{2}-[0-9]{2}'; then
    ok_time=1
  fi

  # 3. 互链段（./ 或 ../ 相对链接）
  if grep -qE '\]\(\./[^)]*\)|\]\(\.\./[^)]*\)' "$f"; then
    ok_link=1
  fi

  # 4. 章节号与文件前缀粗一致性
  base=$(basename "$f" .md)
  dirnum=${base%%-*}
  fileno=$(echo "$base" | cut -d'-' -f2)
  expected="${dirnum#0}.${fileno#0}"
  first=$(grep -m1 -oE '^#{1,6} [0-9]+\.[0-9]+' "$f" | head -1 | awk '{print $2}')
  if [ -n "$first" ]; then
    case "$first" in
      "$expected"*) ok_chap=1 ;;
    esac
  fi

  score=$((ok_conf + ok_time + ok_link + ok_chap))
  if [ "$score" -eq 4 ]; then
    echo "[PASS] $rel ($lines 行)"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $rel ($lines 行, $score/4 项通过)"
    FAIL=$((FAIL + 1))
  fi

  label_conf="FAIL"; [ "$ok_conf" -eq 1 ] && label_conf="OK"
  label_time="FAIL"; [ "$ok_time" -eq 1 ] && label_time="OK"
  label_link="FAIL"; [ "$ok_link" -eq 1 ] && label_link="OK"
  label_chap="FAIL"; [ "$ok_chap" -eq 1 ] && label_chap="OK"
  echo "  - 置信标注: $label_conf | 时效/更新: $label_time | 互链: $label_link | 章节一致性: $label_chap"
done < "$TMPDIR/sample.txt"

echo "---"
echo "PASS=$PASS FAIL=$FAIL 样本数=$((PASS+FAIL)) 总行数=${TOTAL_LINES}"
if [ "$FAIL" -eq 0 ]; then
  echo "✅ 抽检通过"
  exit 0
else
  echo "❌ 抽检存在 FAIL"
  exit 1
fi
