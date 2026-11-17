# Testing/fixtures/ 夹具层规范

> **本文档定位**: 定义项目测试用例所需数据、配置、环境骨架的命名、隔离、生命周期与注册关系。夹具是被测系统的"输入资产"，本身也需要版本化与可重复性保证。

## 1. 命名规范

- 所有夹具文件以 `test-` 前缀开头，如 `test-data-orders.json`、`docker-compose-test-env.yml`。
- 数据夹具：`test-data-<领域>.<格式>`，JSON/CSV/YAML 均可。
- 配置夹具：`test-<组件>-<用途>.<yml|properties|conf>`。
- 环境骨架：`docker-compose-test-env.yml` 为本地多系统最小共存环境；生产级全量 compose 引用 `topics/config-templates/`。

## 2. 隔离原则

- 夹具不得硬编码生产环境地址、密码、证书路径。
- 测试 topic/队列名必须以 `test.` 或 `tc-` 开头，避免与生产 topic 冲突。
- 同一用例运行后产生的残留数据由 hermes L1 清理动作负责回收。

## 3. 生命周期

1. **预置**：随仓库版本化，变更走评审。
2. **加载**：用例前置条件中显式声明夹具路径。
3. **运行**：夹具数据在用例执行期间保持只读；写操作定向到临时副本。
4. **清理**：测试结束后删除临时 topic/队列/容器/卷，保留原始夹具不变。

## 4. 与 test-registry.tsv 的关系

`Testing/test-registry.tsv` 登记每个用例的 ID、目标文档、脚本、环境、所需夹具。新增夹具时：

- 在对应用例行更新 `fixtures` 列；
- 在本 README 增补夹具说明；
- 若夹具被多个用例共用，在 `test-registry.tsv` 中重复列出以保证 traceability。

## 5. 当前夹具清单

| 文件名 | 用途 | 关联用例 |
| -------- | ------ | ---------- |
| `test-data-orders.json` | 电商订单测试数据（10 条，含边界值） | TC-BIZ-01~04 |
| `docker-compose-test-env.yml` | Kafka/NATS/RabbitMQ 三系统最小共存环境 | TC-BIZ-01~12、TC-INT-09~12 |

## 6. 夹具版本控制约定

- 夹具与仓库代码同版本；修改夹具必须随用例变更一起提交。
- 破坏性变更（字段删除、默认值改变、环境拓扑调整）须：
  1. 在提交信息中标注 `BREAKING(fixture)`；
  2. 同步更新所有依赖该夹具的用例；
  3. 在 TEST-08 覆盖矩阵中记录变更影响范围。
- 非破坏性新增字段可直接补充，但应在 README 清单中说明。

## 7. 引用示例

用例中引用夹具时应写相对路径：

```text
前置条件:
  - 夹具: Testing/fixtures/test-data-orders.json
  - 环境: Testing/fixtures/docker-compose-test-env.yml
```

脚本中加载夹具：

```bash
FIXTURE="Testing/fixtures/test-data-orders.json"
[[ -f "$FIXTURE" ]] || { echo "SKIP: fixture missing"; exit 2; }
```

## 8. 贡献检查清单

- [ ] 新夹具已按 `test-*` 命名
- [ ] 无生产敏感信息
- [ ] 已在 `test-registry.tsv` 登记
- [ ] 已在本文档夹具清单中说明
- [ ] JSON/YAML 已通过语法校验（`python -m json.tool` / `yamllint`）
- [ ] 若修改现有夹具，已评估对依赖用例的影响

---

**最后更新**: 2026-11-18
