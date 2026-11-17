#!/usr/bin/env bash
# hermes 任务包生成器（TEST-09 §T.09.3 实现）
# 用法: hermes-task-gen.sh [--plan nightly|weekly|pre-release|--all|--drift <文件列表>|--help]
# 输入: test-registry.tsv + 内嵌"周期-环境-用例对照表"
# 输出: Testing/task-packages/<plan>.yaml
# 退出码: 0=成功；1=参数/环境异常；2=校验失败
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
REGISTRY="${REGISTRY:-$SCRIPT_DIR/test-registry.tsv}"
OUT_DIR="$PROJECT_ROOT/Testing/task-packages"
DATE="$(date +%Y-%m-%d)"

VALID_ENGINES="local-git-bash podman docker k8s"

usage() {
  cat <<'EOF'
用法: hermes-task-gen.sh [选项]
  --plan <nightly|weekly|pre-release>   生成单个任务包
  --all                                  生成三个周期任务包
  --drift "文件1 文件2 ..."              输出 doc_refs 命中这些文件的用例 ID（精确+子串两级匹配）
  --help                                 显示本帮助
环境变量:
  REGISTRY=path/to/test-registry.tsv     指定用例注册表（默认同目录）
EOF
}

# 校验 engine 是否合法
validate_engine() {
  local engine="$1" plan="$2" env="$3"
  if [[ -z "$engine" ]]; then
    echo "[VALIDATE-FAIL] plan=$plan env=$env engine 为空" >&2
    return 1
  fi
  if [[ " $VALID_ENGINES " != *" $engine "* ]]; then
    echo "[VALIDATE-FAIL] plan=$plan env=$env engine='$engine' 不在合法枚举 ($VALID_ENGINES)" >&2
    return 1
  fi
  return 0
}

# 校验 case.id 在注册表中存在
validate_case_id() {
  local case_id="$1" plan="$2" env="$3"
  if [[ -z "$case_id" ]]; then
    echo "[VALIDATE-FAIL] plan=$plan env=$env case.id 为空" >&2
    return 1
  fi
  if ! awk -F'\t' -v id="$case_id" '$1==id {found=1} END {if(found){exit 0}else{exit 1}}' "$REGISTRY"; then
    echo "[VALIDATE-FAIL] plan=$plan env=$env case.id='$case_id' 不在注册表 $REGISTRY" >&2
    return 1
  fi
  return 0
}

# 校验 artifacts 路径以 results/<plan-id>/ 开头
validate_artifact_path() {
  local path="$1" plan_id="$2" plan="$3" env="$4" case_id="$5"
  if [[ -z "$path" ]]; then
    echo "[VALIDATE-FAIL] plan=$plan env=$env case=$case_id artifacts 路径为空" >&2
    return 1
  fi
  local prefix="results/${plan_id}/"
  if [[ "$path" != "$prefix"* ]]; then
    echo "[VALIDATE-FAIL] plan=$plan env=$env case=$case_id artifacts 路径 '$path' 必须以 'results/${plan_id}/' 开头" >&2
    return 1
  fi
  return 0
}

# 生成 YAML 数组字面量
yaml_array() {
  local items=($@)
  if [[ ${#items[@]} -eq 0 ]]; then
    echo "[]"
    return
  fi
  local out="["
  local i
  for i in "${!items[@]}"; do
    out+="\"${items[$i]}\""
    if [[ $i -lt $((${#items[@]} - 1)) ]]; then
      out+=", "
    fi
  done
  out+="]"
  echo "$out"
}

# 根据 case_id 推断脚本与参数（内嵌映射）
case_script_and_args() {
  local case_id="$1"
  local script args
  case "$case_id" in
    TC-DEP-05)   script="validate-config.sh"; args=(kafka topics/config-templates/kafka-server.properties.template) ;;
    TC-DEP-06)   script="validate-config.sh"; args=(nats topics/config-templates/nats-server.conf.template) ;;
    TC-DEP-08)   script="validate-config.sh"; args=(nats topics/config-templates/nats-server.conf.template) ;;
    TC-DEP-08c)  script="validate-config.sh"; args=(rabbitmq topics/config-templates/rabbitmq.conf.template) ;;
    TC-DEP-08d)  script="validate-config.sh"; args=(redis topics/config-templates/redis-stream-config.conf) ;;
    TC-DEP-01)   script="mq-smoke-test.sh";  args=(kafka) ;;
    TC-DEP-02)   script="mq-smoke-test.sh";  args=(nats) ;;
    TC-DEP-03)   script="mq-smoke-test.sh";  args=(rabbitmq) ;;
    TC-DEP-04)   script="mq-smoke-test.sh";  args=(all) ;;
    TC-DEP-04c)  script="-";                  args=() ;;
    TC-DEP-04d)  script="-";                  args=() ;;
    TC-DEP-10)   script="upgrade-check.sh";   args=(kafka) ;;
    TC-DEP-11b)  script="upgrade-check.sh";   args=(nats) ;;
    TC-DEP-11c)  script="upgrade-check.sh";   args=(rabbitmq) ;;
    TC-INT-09)   script="-";                  args=() ;;
    TC-INT-10)   script="message-test.sh";    args=(functional) ;;
    TC-INT-11)   script="message-test.sh";    args=(performance) ;;
    TC-INT-12)   script="message-test.sh";    args=(reliability) ;;
    TC-CLU-01)   script="chaos-test.sh";      args=(kafka network) ;;
    TC-CLU-02)   script="chaos-test.sh";      args=(nats network) ;;
    TC-CLU-03)   script="chaos-test.sh";      args=(rabbitmq network) ;;
    TC-CLU-06b)  script="chaos-test.sh";      args=(kafka partition) ;;
    TC-CLU-06c)  script="chaos-test.sh";      args=(nats server) ;;
    TC-OBS-04)   script="alert-quality-check.sh"; args=(--week) ;;
    TC-OBS-08)   script="benchmark.sh";       args=(kafka 30 1000) ;;
    *)
      # fallback：从注册表读取 script 列，无参
      script="$(awk -F'\t' -v id="$case_id" '$1==id {print $3}' "$REGISTRY" | head -1)"
      args=()
      ;;
  esac
  echo "$script"
  for a in "${args[@]}"; do echo "$a"; done
}

# 输出单个 environment 的 YAML 片段
emit_environment() {
  local plan="$1" env="$2" engine="$3" precheck="$4" cases_csv="$5" plan_id="$6"
  shift 6
  local cases=()
  local c
  IFS=',' read -r -a cases <<< "$cases_csv"

  echo "  - name: $env"
  echo "    engine: $engine"
  echo "    precheck: $precheck"
  echo "    cases:"
  for c in "${cases[@]}"; do
    c="$(echo "$c" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    local sa=($(case_script_and_args "$c"))
    local script="${sa[0]:--}"
    local args=()
    if [[ ${#sa[@]} -gt 1 ]]; then
      args=("${sa[@]:1}")
    fi
    echo "      - id: $c"
    if [[ "$script" == "-" || -z "$script" ]]; then
      echo "        script: \"-\""
      echo "        args: []"
    else
      echo "        script: ./topics/scripts/$script"
      echo "        args: $(yaml_array "${args[@]}")"
    fi
    echo "        artifacts: [\"results/${plan_id}/${env}-${c}.json\"]"
  done
}

# 生成完整 YAML 并执行四项校验
generate_plan() {
  local plan="$1"
  local plan_id="${plan}-${DATE}"
  local yaml=""
  local errors=0
  declare -A seen_cases

  yaml+="# hermes task package: $plan\n"
  yaml+="# generated by hermes-task-gen.sh on $DATE\n"
  yaml+="plan:\n"
  yaml+="  id: $plan_id\n"
  yaml+="  trigger: $plan\n"
  yaml+="  runner: hermes\n"
  yaml+="environments:\n"

  case "$plan" in
    nightly)
      yaml+="$(emit_environment "$plan" E0 local-git-bash "./topics/scripts/hermes-env-precheck.sh" "TC-DEP-05,TC-DEP-06,TC-DEP-08,TC-DEP-08c,TC-DEP-08d" "$plan_id")\n"
      yaml+="$(emit_environment "$plan" E2 docker "./topics/scripts/hermes-env-precheck.sh" "TC-DEP-01,TC-DEP-02,TC-DEP-03" "$plan_id")\n"
      ;;
    weekly)
      yaml+="$(emit_environment "$plan" E2 docker "./topics/scripts/hermes-env-precheck.sh" "TC-DEP-01,TC-DEP-02,TC-DEP-03,TC-DEP-04,TC-DEP-04c,TC-DEP-04d,TC-DEP-10,TC-DEP-11b,TC-DEP-11c,TC-INT-09,TC-INT-10,TC-INT-11,TC-INT-12" "$plan_id")\n"
      ;;
    pre-release)
      yaml+="$(emit_environment "$plan" E3 k8s "./topics/scripts/hermes-env-precheck.sh" "TC-CLU-01,TC-CLU-02,TC-CLU-03,TC-CLU-06b,TC-CLU-06c,TC-OBS-04,TC-OBS-08" "$plan_id")\n"
      ;;
    *)
      echo "[ERROR] 未知 plan: $plan" >&2
      return 1
      ;;
  esac

  yaml+="artifacts:\n"
  yaml+="  base_dir: results/$plan_id\n"
  yaml+="  formats: [json, log]\n"

  # 四项校验
  local engine env case_id artifact
  local env_cases_yaml="$(echo -e "$yaml" | awk '/^  - name:/{env=$3} /^    engine:/{engine=$2} /^      - id:/{case_id=$3; gsub(/"/, "", case_id); print env "|" engine "|" case_id}')"
  while IFS='|' read -r env engine case_id; do
    case_id="$(echo "$case_id" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    validate_engine "$engine" "$plan" "$env" || errors=$((errors+1))
    validate_case_id "$case_id" "$plan" "$env" || errors=$((errors+1))
    artifact="results/${plan_id}/${env}-${case_id}.json"
    validate_artifact_path "$artifact" "$plan_id" "$plan" "$env" "$case_id" || errors=$((errors+1))
    if [[ -n "${seen_cases[$case_id]:-}" ]]; then
      echo "[VALIDATE-FAIL] plan=$plan 发现重复 case_id: $case_id" >&2
      errors=$((errors+1))
    fi
    seen_cases[$case_id]=1
  done <<< "$env_cases_yaml"

  if [[ $errors -gt 0 ]]; then
    echo "[ERROR] $plan 任务包校验失败，共 $errors 项错误，退出码 2" >&2
    return 2
  fi

  mkdir -p "$OUT_DIR"
  local out_file="$OUT_DIR/${plan}.yaml"
  echo -e "$yaml" > "$out_file"
  echo "$out_file"
  return 0
}

# --drift：根据文件列表匹配 doc_refs，精确+子串两级
drift_cases() {
  local files_csv="$1"
  if [[ -z "$files_csv" ]]; then
    echo "[ERROR] --drift 需要文件列表参数" >&2
    return 1
  fi
  if [[ ! -f "$REGISTRY" ]]; then
    echo "[ERROR] 注册表不存在: $REGISTRY" >&2
    return 1
  fi
  local files=()
  IFS=' ' read -r -a files <<< "$files_csv"
  awk -F'\t' -v files_str="$files_csv" '
    NR==1 || $1 ~ /^#/ || $1=="id" { next }
    {
      split(files_str, files, " ");
      for (i in files) {
        f = files[i];
        if (f == "") continue;
        # 精确匹配（按逗号拆分）
        n = split($5, refs, ",");
        for (j=1; j<=n; j++) {
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", refs[j]);
          if (refs[j] == f) { print $1; next; }
        }
        # 子串匹配
        if (index($5, f) > 0) { print $1; next; }
      }
    }
  ' "$REGISTRY" | sort -u
  return 0
}

# 主入口
main() {
  local plan="" do_all=0 drift_files=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --plan)
        plan="${2:-}"; shift 2 ;;
      --all)
        do_all=1; shift ;;
      --drift)
        drift_files="${2:-}"; shift 2 ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        echo "[ERROR] 未知参数: $1" >&2; usage; exit 1 ;;
    esac
  done

  if [[ -n "$drift_files" ]]; then
    drift_cases "$drift_files"
    exit $?
  fi

  if [[ "$do_all" -eq 1 ]]; then
    local rc=0
    for p in nightly weekly pre-release; do
      generate_plan "$p" || rc=2
    done
    exit $rc
  fi

  if [[ -z "$plan" ]]; then
    echo "[ERROR] 必须指定 --plan <plan> 或 --all" >&2
    usage
    exit 1
  fi

  case "$plan" in
    nightly|weekly|pre-release)
      generate_plan "$plan"
      exit $?
      ;;
    *)
      echo "[ERROR] 未知 plan: $plan" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
