# topics/archive/ 归档目录

本目录用于存放项目演进过程中从活跃位置迁出的历史内容，保持主目录整洁并保留可检索的历史记录。

## 目录结构

```text
topics/archive/
├── README.md                 # 本说明
├── changelog/                # CHANGELOG.md 滚动归档
│   └── YYYY-MM.md            # 按版本条目起始月份命名的归档文件
└── [其他未来归档子目录]       # 按需要新增，须在本 README 登记规则
```

## CHANGELOG 归档规则

1. **触发条件**：`topics/CHANGELOG.md` 单文件行数超过 400 行。
2. **归档粒度**：将起始月份在 6 个月前的完整版本条目整体移出。
3. **文件命名**：`topics/archive/changelog/YYYY-MM.md`，其中 `YYYY-MM` 是被归档版本条目的起始月份（取该条目中最早的日期）。
4. **原文指针**：在 `CHANGELOG.md` 原条目位置保留一行 Markdown 指针，格式示例：

   ```markdown
   > [3.12.0] 条目已归档至 topics/archive/changelog/2026-05.md
   ```

5. **索引要求**：归档文件头部保留原版本号与日期列表，便于快速定位。
6. **禁止反向引用**：已归档的历史完成度报告类文件不得被任何活跃文档链接引用（参见 AGENTS.md §5、§6）。

## 维护责任

- 每次触发归档后，同步检查 `topics/CHANGELOG.md` 顶部归档规则段中的“当前状态”描述。
- 新增归档子目录前，须先更新本 README 并说明规则。

**最后更新**: 2026-11-18
