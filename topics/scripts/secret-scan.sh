#!/usr/bin/env bash
# 仓库机密泄露扫描（批次194，E0 第十三步）
# 用途：扫描 git 跟踪文件中的高信号机密形态（私钥头/AWS/GitHub/Slack/Google/OpenAI），
#        complement sec-baseline-scan.sh（后者只扫 config-templates 安全配置项，不扫仓库内容）。
# 设计取舍：
#   - 只收高信号 token 形态（低误报）；通用 password= 形态不收（config-templates 占位值必误报）；
#   - JWT（eyJ...）形态不收——KB 安全文档大量格式示例会误报，缺口由 SEC 基线 transport 加密项覆盖；
#   - 扫描面=git 跟踪文件（git grep，含已暂存新文件）；自测 fixture 目录显式排除。
# 用法：secret-scan.sh [--json] [--selftest]
# 退出码：0=无泄露；1=存在泄露（HIGH）；2=用法/环境异常（git 缺失=SKIP 语义，由 E0 步骤包装）
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT" || exit 2

JSON_OUT=0
SELFTEST=0
for a in "$@"; do
  case "$a" in
    --json) JSON_OUT=1 ;;
    --selftest) SELFTEST=1 ;;
    --help) echo "用法: secret-scan.sh [--json] [--selftest]"; exit 2 ;;
    *) echo "未知参数: $a" >&2; exit 2 ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "SKIP: git 未安装（secret-scan 需 git grep）"
  exit 2
fi

# 高信号机密形态（名称\t正则）。判定依据=各厂商 token 公开格式规范。
PATTERNS=(
  "PEM_PRIVATE_KEY|-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY( BLOCK)?-----"
  "AWS_ACCESS_KEY_ID|AKIA[0-9A-Z]{16}"
  "GITHUB_TOKEN|(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36}"
  "SLACK_TOKEN|xox[baprs]-[A-Za-z0-9-]{10,}"
  "GOOGLE_API_KEY|AIza[0-9A-Za-z_-]{35}"
  "SLACK_WEBHOOK|https://hooks\.slack\.com/services/T[A-Z0-9]{8,}/B[A-Z0-9]{8,}/[A-Za-z0-9]{20,}"
  "OPENAI_SK|sk-[A-Za-z0-9]{20,}"
)
FIXTURE_DIR="Testing/fixtures/secret-scan"

scan() { # 输出 HIT 行 + 返回命中数；$1=额外 git grep 路径参数（selftest 用）
  local extra_path="${1:-}" hits=0
  local pat name regex out
  for pat in "${PATTERNS[@]}"; do
    name="${pat%%|*}"
    regex="${pat#*|}"
    if [ -n "$extra_path" ]; then
      out="$(git grep -n -I -E -e "$regex" -- "$extra_path" 2>/dev/null)"
    else
      out="$(git grep -n -I -E -e "$regex" -- . ":!$FIXTURE_DIR" 2>/dev/null)"
    fi
    if [ -n "$out" ]; then
      while IFS= read -r line; do
        hits=$((hits + 1))
        local f l rest
        f="${line%%:*}"
        l="${line#*:}"; l="${l%%:*}"
        rest="${line#*:*:}"
        rest="$(printf '%s' "$rest" | cut -c1-80)"
        echo "HIT $name $f:$l: $rest"
      done <<< "$out"
    fi
  done
  return "$hits"
}

if [ "$SELFTEST" -eq 1 ]; then
  pos="$(scan "$FIXTURE_DIR")"
  pos_n=$?
  neg_file="$(mktemp)"
  printf 'password=changeme\nuser=guest\nAKIA 格式示例（无完整 key）\n普通正文一行\n' > "$neg_file"
  neg_out="$(git grep -n -I -E -e "$(printf '%s' "${PATTERNS[1]#*|}")" -- "$neg_file" 2>/dev/null)"
  rm -f "$neg_file"
  echo "SELFTEST positive_hits=$pos_n（期望 ≥6 类形态检出）"
  echo "$pos" | head -12
  if [ "$pos_n" -ge 6 ] && [ -z "$neg_out" ]; then
    echo "SELFTEST_OK"
    exit 0
  fi
  echo "SELFTEST_FAIL"
  exit 2
fi

HITS_TEXT="$(scan)"
HITS=$?

if [ "$JSON_OUT" -eq 1 ]; then
  printf '{"hits":%d}\n' "$HITS"
fi

if [ "$HITS" -gt 0 ]; then
  printf '%s\n' "$HITS_TEXT"
  echo "SECRET_SCAN HITS=$HITS（HIGH=机密泄露不可降级；删除或轮换密钥后重跑）"
  exit 1
fi
echo "SECRET_SCAN HITS=0（${#PATTERNS[@]} 类高信号形态，含自测 fixture 排除）"
exit 0
