#!/bin/bash
# 知识库规范自检脚本（TEST-06 配套）
# 用法: doc-self-check.sh [quick|full|--skill-drift]
# 退出码: 0=无 ERROR; 1=存在 ERROR (WARN 不置失败位)
set -u

MODE=${1:-"quick"}
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 1

ERRORS=0
WARNS=0
err()  { echo "[ERROR] $1"; ERRORS=$((ERRORS+1)); }
warn() { echo "[WARN]  $1"; WARNS=$((WARNS+1)); }
ok()   { echo "[OK]    $1"; }

TODAY=$(date +%F)
echo "=== 知识库规范自检 ($MODE) $TODAY ==="

# ---------- 1. 禁用表述扫描 ----------
# AGENTS.md §5 红线：禁止对项目完成度宣称"100% 完成/生产就绪"。
# 说明：产品 GA 状态的"生产就绪"（如 "Kafka 3.3 生产就绪"）是合法产品事实，仅状态类文档扫该词；
#      COMPREHENSIVE_REVIEW 为历史档案，降级 WARN。
while IFS= read -r line; do
  err "禁用表述(100%完成): $line"
done < <(grep -rnE '100% *(完成|覆盖)' --include='*.md' topics README.md 2>/dev/null \
  | grep -vE '禁止|不得|❌|违反' | grep -v 'COMPREHENSIVE_REVIEW_AND_RECOMMENDATIONS.md')
while IFS= read -r line; do
  err "禁用表述(生产就绪): $line"
done < <(grep -nE '生产就绪' topics/PROJECT_STATUS.md README.md 2>/dev/null | grep -vE '禁止|不得|❌|违反')
while IFS= read -r line; do
  warn "历史档案含完成度宣称(允许保留但需知情): $line"
done < <(grep -nE '100% *(完成|覆盖)|生产就绪' topics/COMPREHENSIVE_REVIEW_AND_RECOMMENDATIONS.md 2>/dev/null)

# ---------- 2. 归档文档引用 (ERROR) ----------
# 已归档 8 个完成度报告不得被引用（仅检查文件名级引用，忽略纯文字叙述）
ARCHIVED='COMPLETION_REPORT|PROJECT_COMPLETION|IMPLEMENTATION_STATUS_FINAL|FINAL_SUMMARY|FINAL_REPORT'
while IFS= read -r line; do
  err "归档文档引用: $line"
done < <(grep -rnE "\\]\([^)]*($ARCHIVED)[^)]*\.md" --include='*.md' topics README.md 2>/dev/null)

# ---------- 3. 相对链接可达性 (ERROR) ----------
# 跳过模板占位链接（含 -NN- 的示意路径，见 TEMPLATES.md）
while IFS= read -r f; do
  d=$(dirname "$f")
  while IFS= read -r link; do
    case "$link" in http*|*'-NN-'*) continue ;; esac
    [ -e "$d/$link" ] || err "死链: $f -> $link"
  done < <(grep -oE '\]\(([^)[:space:]]+\.md)(#[^)]*)?\)' "$f" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//; s/#.*$//')
done < <(find topics -type f -name '*.md'; echo README.md)

# ---------- 4. 定位声明 (ERROR, 02/03 系列主题文档，README 除外) ----------
for f in topics/0[23]-*/*.md; do
  case "$f" in */README.md) continue ;; esac
  [ -f "$f" ] || continue
  head -8 "$f" | grep -q '本文档定位' || err "缺定位声明: $f"
done

# ---------- 5. 代码块语言标注 (WARN) ----------
# 注意：FNR==1 重置 fence 状态（多文件 awk 状态不跨文件泄漏）
while IFS= read -r line; do
  warn "代码块缺语言标注: $line"
done < <(find topics -type f -name '*.md' -exec awk 'FNR==1{infence=0} /^```/{ if (!infence && $0=="```") print FILENAME":"FNR; infence=!infence }' {} + 2>/dev/null)

# ---------- 6. 最后更新日期 (WARN) ----------
for f in topics/0[1-4]-*/*.md topics/AI_Skill/*.md topics/Testing/*.md; do
  [ -f "$f" ] || continue
  tail -5 "$f" | grep -qE '\*\*最后更新\*\*: [0-9]{4}-[0-9]{2}-[0-9]{2}' || warn "缺最后更新或格式错误: $f"
done

# ---------- 7. INDEX 登记 (WARN) ----------
if [ -f topics/INDEX.md ]; then
  for f in topics/0[1-4]-*/*.md topics/AI_Skill/*.md topics/Testing/*.md; do
    case "$f" in */README.md) continue ;; esac
    [ -f "$f" ] || continue
    base=$(basename "$f" .md)
    grep -q "$base" topics/INDEX.md || warn "未在 INDEX.md 登记: $base"
  done
fi

# ---------- 8. 密度抽样 (WARN, full 模式；README 除外) ----------
if [ "$MODE" = "full" ]; then
  for f in topics/0[1-4]-*/*.md; do
    case "$f" in */README.md) continue ;; esac
    [ -f "$f" ] || continue
    lines=$(wc -l < "$f")
    [ "$lines" -lt 80 ] && warn "骨架风险(${lines}行<80): $f"
  done
fi

# ---------- 9. 统计对账 ----------
count_dir() { find "$1" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l; }
T01=$(count_dir "topics/01-基础概念与对比分析")
T02=$(count_dir "topics/02-场景驱动架构设计")
T03=$(count_dir "topics/03-架构与运维实践")
T04=$(count_dir "topics/04-动态系统论与演化分析")
AIS=$(count_dir "topics/AI_Skill")
TST=$(count_dir "topics/Testing")
EX=$(find topics/examples -type f 2>/dev/null | wc -l)
CT=$(find topics/config-templates -type f 2>/dev/null | wc -l)
SC=$(find topics/scripts -type f -name '*.sh' 2>/dev/null | wc -l)
echo "--- 实地计数: 01=$T01 02=$T02 03=$T03 04=$T04 AI_Skill=$AIS Testing=$TST examples=$EX config=$CT scripts=$SC"
[ -f topics/PROJECT_STATUS.md ] && grep -qE '文档统计' topics/PROJECT_STATUS.md || warn "PROJECT_STATUS.md 缺统计节，无法对账"

# ---------- 10. 技能漂移对账 (WARN, full / --skill-drift) ----------
if [ "$MODE" = "--skill-drift" ] || [ "$MODE" = "full" ]; then
  if [ -d skills ]; then
    while IFS= read -r sk; do
      derived=$(awk -F'"' '/derived-at:/{print $2; exit}' "$sk")
      [ -z "$derived" ] && { warn "缺 derived-at: $sk"; continue; }
      while IFS= read -r doc; do
        doc=$(echo "$doc" | xargs)
        [ -z "$doc" ] && continue
        if [ -f "$doc" ]; then
          mtime=$(date -r "$doc" +%F 2>/dev/null || echo "")
          [ -n "$mtime" ] && [ "$mtime" \> "$derived" ] && \
            warn "技能漂移: $sk 源 $doc 更新于 $mtime 晚于派生日 $derived"
        else
          warn "技能源文档不存在: $sk -> $doc"
        fi
      done < <(awk '
        /source-doc: *\|? *$/ { flag=1; next }
        /source-doc: *\S/ { sub(/^[^:]*:[ ]*/,""); gsub(/^["'"'"']|["'"'"']$/,""); if ($0!="") print; next }
        flag && /^  [a-zA-Z-]+:/ { flag=0 }
        flag { line=$0; gsub(/^[ \t]+|[ \t]+$/,"",line); if (line!="" && line!="|") print line }
      ' "$sk")
    done < <(find skills -name SKILL.md 2>/dev/null)
  else
    ok "skills/ 目录不存在，跳过技能对账"
  fi
fi

# ---------- 11. 外链健康巡检 (WARN, full 模式；403/超时跳过，仅 404/410 告警；并行 8) ----------
if [ "$MODE" = "full" ]; then
  echo "--- 外链巡检（仅 404/410 告警；403 与超时跳过；并行 8）"
  grep -rhoE '\]\(https?://[^)[:space:]]+\)' --include='*.md' topics README.md 2>/dev/null | \
    sed -E 's/^\]\(//; s/\)$//' | sort -u > _urls_tmp.txt
  url_count=$(wc -l < _urls_tmp.txt)
  echo "--- 共 $url_count 个唯一外链（检查上限 300）"
  head -300 _urls_tmp.txt | xargs -P 8 -I {} bash -c '
    url="{}"
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 -L -I "$url" 2>/dev/null || echo "000")
    if [ "$code" = "405" ] || [ "$code" = "501" ] || [ "$code" = "404" ]; then
      # HEAD 404 可能是站点拒 HEAD（如 csrc.nist.gov）——GET 复核
      get_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 -L "$url" 2>/dev/null || echo "000")
      [ "$get_code" != "404" ] && [ "$get_code" != "410" ] && code="$get_code"
    fi
    case "$code" in
      404|410) echo "BADCURL ${code} $url" ;;
    esac
  ' > _badurls_tmp.txt 2>/dev/null
  while IFS= read -r line; do
    warn "外链失效: $(echo "$line" | cut -d" " -f2-)（$(echo "$line" | cut -d" " -f1)）"
  done < _badurls_tmp.txt
  checked=$(( $(head -300 _urls_tmp.txt | wc -l) ))
  rm -f _urls_tmp.txt _badurls_tmp.txt
  echo "--- 外链巡检完成（检查 $checked 个）"
fi

# ---------- 汇总 ----------
echo "============================="
echo "ERROR=$ERRORS WARN=$WARNS"
if [ "$ERRORS" -eq 0 ]; then echo "✅ 自检通过"; else echo "❌ 存在 ERROR，请修复后重跑"; fi
exit "$ERRORS"
