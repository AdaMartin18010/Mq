#!/bin/bash
# mq-doc-lint 技能脚本（薄封装）
# 权威版本: topics/scripts/doc-self-check.sh（修改请以权威版本为准，本文件仅提供技能内入口）
# 派生日期: 2026-11-17
set -e
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
exec bash "$ROOT/topics/scripts/doc-self-check.sh" "$@"
