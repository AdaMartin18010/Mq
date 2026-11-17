# MCP 化出口评估（知识库 → MCP Server）

> **定位**: 批次 92。评估把本知识库封装为 MCP（Model Context Protocol）server 的方案——2026 年 AI 工程化的国际主流接入方式（MCP 已捐赠 Linux Foundation，2025-03 起 Streamable HTTP 传输）。
> **本文档只做评估，不做实现**；实现列入后续批次。

## 一、价值主张【论证】

1. **AI 原生访问**：agent（含本项目的 hermes 体系）以标准协议检索知识库，替代"整库 grep + 长上下文灌注"的粗方式；
2. **技能与知识的管道打通**：AI_Skills/ 的 7 个技能目前靠文件约定触发；MCP tools 化后是显式可发现接口；
3. **契约语义测试的 AI 执行者**：TC-SKL 回放用例可由具备 MCP 能力的 agent 直接执行，闭环"知识→测试"。

## 二、映射方案（评估稿）

| MCP 概念 | 知识库映射 | 说明 |
| ---- | ---- | ---- |
| resources | topics/01~04 文档树（按 URI 暴露，如 `mq://topics/01-63`） | 只读；支持目录列举 |
| tools | 脚本资产工具化：`doc-self-check` / `contract-spec-check` / `decision-check` / `tc-assert-check` / `sec-baseline-scan` | 每个 tools/scripts 一个 tool，参数=脚本参数 |
| tools | 知识查询：`concept-lookup`（01-58 卡片检索）/ `decision-tree`（01-59 走树） | 检索层可用简单索引（search-index/ 已有生成物） |
| prompts | 模板：选型咨询/文档审计/契约评审 prompt 模板 | 与 AI_Skills 触发词对齐 |

## 三、技术路线比选【论证】

| 路线 | 实现量 | 依赖 | 评估 |
| ---- | ---- | ---- | ---- |
| A. 官方 TS/Python SDK 手写 server | 中 | node/python 常驻进程 | 最标准；与 CI 同栈 |
| B. FastMCP（Python）声明式 | 低 | python+mcp 包 | 最快落地；生态活跃 |
| C. 包装现有 CLI（每脚本一个 stdio 封装） | 低 | bash+python | 零架构变更，MVP 首选 |

**建议**：MVP 走 C→B 渐进：先用 stdio 薄封装暴露 5 个校验脚本（B 面工具），验证使用率后再做 resources 全量暴露。语言：中文接口描述。

## 四、风险与边界

1. **只读纪律**：MCP 工具层只暴露只读/校验类脚本；修复类（hermes-fix-l1 等）永不暴露给通用 agent（L0-L3 边界）；
2. **时效纪律**：MCP 描述中的版本事实走 E0 现有机制，不加新数据源；
3. **发布形态**：随仓库发布（server 代码入 AI_Skills/mcp-server/），不单独发版。

## 五、决策请求

实现批次（含 FastMCP 依赖选型核准、5 个校验脚本 tools 化、resources URI 规范、与 TC-SKL 执行打通）待用户确认后排期；预估 1 个批次（2-3 文件 + 测试）。

---

**最后更新**: 2026-11-18
