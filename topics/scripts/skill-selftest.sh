#!/usr/bin/env bash
# 动态验证④：技能动态自测（批次196）——7 技能 SKILL.md frontmatter + 引用路径真实可达
# 复算面：① frontmatter 必有 name:/description: ② 正文引用的 references//scripts/ 相对路径逐一切实存在
# RC: 0=全过；1=存在缺失
set -u
cd "$(cd "$(dirname "$0")/../.." && pwd)" || exit 1
fail=0; n=0
for d in AI_Skills/skills/*/; do
  s="$(basename "$d")"
  n=$((n+1))
  f="$d/SKILL.md"
  [ -f "$f" ] || { echo "FAIL: $s 缺 SKILL.md"; fail=1; continue; }
  grep -q "^name:" "$f" || { echo "FAIL: $s frontmatter 缺 name:"; fail=1; }
  grep -q "^description:" "$f" || { echo "FAIL: $s frontmatter 缺 description:"; fail=1; }
  # 引用路径解析：references/ 与 scripts/ 开头的相对 token
  while read -r p; do
    [ -e "$d$p" ] || { echo "FAIL: $s 引用不可达: $p"; fail=1; }
  done < <(grep -oE '\b(references|scripts)/[^ )"（）]+' "$f" | sort -u)
done
echo "SKILL_SELFTEST skills=$n fail=$fail"
if [ "$fail" -eq 0 ]; then
  echo "PASS: 技能动态自测（$n 技能 frontmatter+引用路径全可达）"
  exit 0
fi
echo "FAIL: 技能动态自测"
exit 1
