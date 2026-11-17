---
name: mq-doc-lint
description: >
  项目知识库规范性自检：密度与结构标准、三级置信标注、02/03 定位声明、INDEX 登记、
  死链与归档引用检测、技能漂移对账，输出可执行的修正清单。
  Use when 文档治理、规范检查、doc lint、索引同步检查、知识库自检、
  AGENTS.md 验收、批次收尾检查、技能漂移对账。
license: Apache-2.0
compatibility: Requires bash, grep, find, awk（Git Bash / Linux 环境）
metadata:
  source-doc: |
    AGENTS.md
    topics/Testing/TEST-06-自我验证机制与脚本说明.md
    topics/scripts/doc-self-check.sh
  derived-at: "2026-11-17"
  mq-system: multi
  project: Mq-knowledge-base
  last-verified: "2026-11-17"
  status: active
---

# 知识库规范性自检

## 适用范围
- 批次收尾验收（AGENTS.md §7.2.4 的自动化部分）
- 文档修改后的结构自检；技能对账（`--skill-drift`）

## 执行
在项目根目录运行（脚本位于 skills 内副本，与 topics/scripts/ 同源，以 topics 版为准）：

```bash
./topics/scripts/doc-self-check.sh quick            # 结构+红线（分钟级）
./topics/scripts/doc-self-check.sh full             # +密度抽样+统计+技能漂移
./topics/scripts/doc-self-check.sh --skill-drift    # 仅技能漂移对账
echo $?   # 0=无 ERROR；1=存在 ERROR
```

## 解读输出
- `[ERROR]`（禁用表述/归档引用/死链/缺定位声明）：必须本批次修复，不修复不收尾。
- `[WARN]`（代码块语言/最后更新日期/INDEX 未登记/密度偏薄/技能漂移）：登记挂账清单，下一批次优先清偿。
- 汇总行 `ERROR=0 WARN=n` 直接粘贴进批次报告。

## 修复原则
1. 只修检测到的问题，不顺手重构无关内容。
2. 修复后复跑至 ERROR=0；WARN 挂账逐条登记。
3. 判定为脚本误报时：改脚本白名单并在脚本注释写明理由（禁止静默忽略）。

## 边界与红线
- 本技能不评估内容**正确性**（那是 TEST-02~04 与评审的事），只管结构合规。
- 不修改受检文件之外的任何文件；脚本本身修改须回放验证（TEST-06 T.06.6）。

## 参考
- scripts/doc-self-check.sh（本技能副本；权威版本 topics/scripts/doc-self-check.sh）
- 规范依据：AGENTS.md §3/§5；机制说明：topics/Testing/TEST-06
