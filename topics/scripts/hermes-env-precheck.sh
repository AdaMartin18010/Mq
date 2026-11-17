#!/usr/bin/env bash
# hermes 环境前置检查脚本（TEST-09 §T.09.4 实现）
# 用途：检测 E0/E1/E2/E3 四级环境可用性，按降级决策表给出处置标记。
# 用法：hermes-env-precheck.sh [--quiet|--help]
# 退出码：0=E0 可用；3=E0 不可用整体 BLOCK；2=存在部分 SKIP（E1/E2/E3 缺失）。
# 兼容性：bash 4+；Windows Git Bash 下不依赖 ss/lsof 等 Linux 专有工具。
set -u

QUIET=0

usage() {
  cat <<'EOF'
用法: hermes-env-precheck.sh [选项]
  --quiet    只输出最终决策行
  --help     显示本帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[ERROR] 未知参数: $1"; usage; exit 2 ;;
  esac
done

log() {
  if [[ "$QUIET" -eq 0 ]]; then
    echo "$1"
  fi
}

# E0: bash>=4.4 + awk + find + 项目仓库存在
check_e0() {
  local bash_ok=0 awk_ok=0 find_ok=0 repo_ok=0
  local bash_major bash_minor
  bash_major="${BASH_VERSINFO[0]}"
  bash_minor="${BASH_VERSINFO[1]}"
  if [[ "$bash_major" -gt 4 ]] || { [[ "$bash_major" -eq 4 ]] && [[ "$bash_minor" -ge 4 ]]; }; then
    bash_ok=1
  fi
  command -v awk >/dev/null 2>&1 && awk_ok=1
  command -v find >/dev/null 2>&1 && find_ok=1
  # 以存在 AGENTS.md 作为项目仓库已 clone 的判据
  if [[ -f "$(cd "$(dirname "$0")/../.." && pwd)/AGENTS.md" ]]; then
    repo_ok=1
  fi

  if [[ "$bash_ok" -eq 1 && "$awk_ok" -eq 1 && "$find_ok" -eq 1 && "$repo_ok" -eq 1 ]]; then
    log "E0 AVAIL (bash ${bash_major}.${bash_minor}, awk, find, repo)"
    return 0
  else
    log "E0 UNAVAIL (bash=${bash_ok} awk=${awk_ok} find=${find_ok} repo=${repo_ok})"
    return 1
  fi
}

# E1: podman + podman compose
check_e1() {
  if command -v podman >/dev/null 2>&1 && podman compose version >/dev/null 2>&1; then
    log "E1 AVAIL (podman + podman compose)"
    return 0
  else
    log "E1 UNAVAIL (podman 或 podman compose 缺失)"
    return 1
  fi
}

# E2: docker + docker compose
check_e2() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    log "E2 AVAIL (docker + docker compose)"
    return 0
  else
    log "E2 UNAVAIL (docker 或 docker compose 缺失)"
    return 1
  fi
}

# E3: kubectl 可连集群
check_e3() {
  if command -v kubectl >/dev/null 2>&1 && kubectl cluster-info >/dev/null 2>&1; then
    log "E3 AVAIL (kubectl cluster-info 可达)"
    return 0
  else
    log "E3 UNAVAIL (kubectl 缺失或 cluster-info 失败)"
    return 1
  fi
}

# 主流程
E0=0 E1=0 E2=0 E3=0

if check_e0; then E0=1; fi
if check_e1; then E1=1; fi
if check_e2; then E2=1; fi
if check_e3; then E3=1; fi

# 按 T.09.4 降级决策表生成整体处置
if [[ "$E0" -eq 0 ]]; then
  echo "DECISION: BLOCK | E0=UNAVAIL E1=N/A E2=N/A E3=N/A | 整体停止，静态检查基线缺失"
  exit 3
fi

# E1/E2 互斥：探测到哪种容器运行时可用即执行对应变体，另一列记 N/A
CONTAINER_MARK="SKIP"
if [[ "$E1" -eq 1 && "$E2" -eq 1 ]]; then
  CONTAINER_MARK="E1/E2"
elif [[ "$E1" -eq 1 ]]; then
  CONTAINER_MARK="E1"
elif [[ "$E2" -eq 1 ]]; then
  CONTAINER_MARK="E2"
fi

E3_MARK="SKIP"
[[ "$E3" -eq 1 ]] && E3_MARK="E3"

# 判断是否存在部分 SKIP
PARTIAL_SKIP=0
if [[ "$CONTAINER_MARK" == "SKIP" ]]; then
  PARTIAL_SKIP=1
fi
if [[ "$E3_MARK" == "SKIP" ]]; then
  PARTIAL_SKIP=1
fi

if [[ "$PARTIAL_SKIP" -eq 0 ]]; then
  echo "DECISION: RUN | E0=AVAIL E1/E2=${CONTAINER_MARK} E3=${E3_MARK} | 全环境可用"
  exit 0
else
  echo "DECISION: SKIP | E0=AVAIL E1/E2=${CONTAINER_MARK} E3=${E3_MARK} | 部分环境缺失，按降级表继续可执行域"
  exit 2
fi
