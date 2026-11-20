#!/usr/bin/env bash
# GAME DAY 故障注入入口（TC-CHA-01~03，批次81）
# 默认 dry-run；--live <case> 真实注入（需用户在场 + 容器运行时可用，podman 首选）
set -u
# 容器运行时: podman 首选, docker 回退（TEST-09 E1/E2 双轨, 可用 MQ_RUNTIME 覆盖）
RT="${MQ_RUNTIME:-$(if command -v podman >/dev/null 2>&1; then echo podman; elif command -v docker >/dev/null 2>&1; then echo docker; fi)}"
CASE_ID="${2:-TC-CHA-01}"
[[ "${1:-}" == "--live" ]] || {
  cat <<PLAN
执行计划（dry-run）：
 TC-CHA-01 broker 僵死:  $RT pause kafka 90s → 观测客户端重连 → unpause → 断言热路径零丢失
 TC-CHA-02 网络分区:     toxiproxy 断链 broker↔consumer 120s → 断言积压增长率 → 恢复 → 追平时间测量
 TC-CHA-03 磁盘压力:     慢盘代理挂载 broker 数据卷 → 观测 ISR 收缩（对照 01-61 §1.61.7 推演表）
 每场景闭环: hermes-diagnose 打标签 → 断言核对 → failbundle 归档（失败）→ audit log
PLAN
  echo "DRY-RUN 完成；--live TC-CHA-0X 需用户在场"; exit 0
}
[[ -n "$RT" ]] || { echo "FAIL: 无容器运行时（podman/docker）"; exit 2; }
bash "$(dirname "$0")/../../topics/scripts/hermes-env-precheck.sh" --quiet | grep -q "E0=AVAIL" || { echo "FAIL: 预检未过"; exit 1; }
echo "LIVE: $CASE_ID 注入骨架就位（完整断言随真实批次补全）"
echo "RESULT: SKIP"; echo "DURATION: 0"; echo "EXIT_CODE: 2"; exit 2
