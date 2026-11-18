# Mq 知识库 MCP Server（MVP）

> 将消息队列知识库以 MCP（Model Context Protocol）server 形式暴露给 AI Agent。只读工具层，封装现有校验/查询脚本。
> **最后更新**: 2026-11-18

## 安装与运行

```bash
cd AI_Skills/mcp-server
pip install -r requirements.txt        # mcp>=1.0.0（含 FastMCP）
python server.py                       # stdio 传输，供 MCP client 连接
python server.py --dry-run             # 无依赖自检：打印将注册的 tools/resources
```

## 客户端配置示例

### Claude Desktop

```json
{
  "mcpServers": {
    "mq-knowledge": {
      "command": "python",
      "args": ["E:/_src/Mq/AI_Skills/mcp-server/server.py"]
    }
  }
}
```

### Kimi Code / 其他 CLI

在配置中添加 stdio server 条目，指向 `AI_Skills/mcp-server/server.py` 即可。

## Tools / Resources 一览

| 类型 | 名称 | 说明 | 对应脚本 |
| ---- | ---- | ---- | ---- |
| tool | `run_doc_check` | 知识库规范自检 | `doc-self-check.sh` |
| tool | `run_contract_check` | AsyncAPI spec 结构校验 | `contract-spec-check.sh` |
| tool | `run_binding_check` | 绑定层字段/层级/登记簿校验 | `contract-binding-check.sh` |
| tool | `run_tc_assert` | TC-BUS 父用例断言校验 | `tc-assert-check.sh` |
| tool | `run_sec_scan` | 安全配置基线扫描 | `sec-baseline-scan.sh` |
| tool | `concept_lookup` | 概念卡 + 关系查询 | `kg-query.py --concept` |
| tool | `kg_judge` | 场景×系统适配判定 | `kg-query.py --judge --explain` |
| resource | `mq://concepts/{name}` | 知识图谱概念卡 | `kg-query.py --concept` |
| resource | `mq://docs/{path}` | 只读文档片段 | 直接读取 `.md` |

## 只读纪律声明

本 server **仅暴露只读/校验类能力**：

- 不暴露 `hermes-fix-l1`、`hermes-self-heal`、`game-day` 等任何修复/执行/混沌脚本；
- 不通过 MCP 对仓库进行任何写入、修复或自动变更；
- 工具层参数使用白名单透传，资源层路径白名单限制为 `topics/`、`Testing/`、`concept/` 下的 `.md` 文件，禁止目录穿越。

该纪律与 `topics/MCP_EXPORT_ASSESSMENT.md` §四「只读纪律」保持一致。

## 与 TC-SKL 技能回放用例的衔接

- `run_doc_check` 支撑 TC-SKL-04/05/06（mq-doc-lint 用例）的真实执行；
- `run_contract_check` / `run_binding_check` / `run_tc_assert` 支撑契约语义测试六层体系（TEST-C1~C3）的静态验证；
- `concept_lookup` / `kg_judge` 支撑 mq-selection、mq-pattern-dlq 等技能的事实溯源与选型判定。

具备 MCP 能力的 Agent 可直接调用上述工具，把 `Testing/05-体系与机制/TEST-14-skill触发回放测试.md` 中的人工/代理回放用例变为可机器触发的验证步骤。

## 调用示例

```json
{
  "tool": "run_doc_check",
  "params": {"mode": "quick"}
}
```

```json
{
  "tool": "concept_lookup",
  "params": {"name": "死信队列"}
}
```

```text
resource mq://docs/topics/01-基础概念与对比分析/01-58-概念卡片.md
resource mq://concepts/死信队列
```

## 错误处理

所有 tool 在脚本缺失、超时、非零退出码或参数非法时返回结构化结果，不抛栈：

```json
{
  "ok": false,
  "error": "脚本返回非零退出码",
  "exit_code": 1,
  "stdout": "...",
  "stderr": "..."
}
```

## 限制说明

- 仅支持 stdio 传输；Streamable HTTP 待后续批次评估；
- 资源层仅暴露 `.md` 文本，不暴露配置模板、脚本源码或二进制文件；
- 工具执行超时固定 300s，超长全量扫描请直接在命令行运行原脚本。

## 参考

- [topics/MCP_EXPORT_ASSESSMENT.md](../../topics/MCP_EXPORT_ASSESSMENT.md) — MCP 化出口评估与路线决策
- [Testing/06-契约语义测试/README.md](../../Testing/06-契约语义测试/README.md) — 契约语义测试体系
- [topics/knowledge-graph/README.md](../../topics/knowledge-graph/README.md) — 机读知识图谱
- [Testing/05-体系与机制/TEST-14-skill触发回放测试.md](../../Testing/05-体系与机制/TEST-14-skill触发回放测试.md) — TC-SKL 用例集
