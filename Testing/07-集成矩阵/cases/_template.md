# 用例模板（_template，复制后改名 TC-<SYS>-<LANG>-<FEAT3>-<NN>.md）

```markdown
        # TC-<SYS>-<LANG>-<FEAT3>-<NN>：<一句话目标>

        > **维度**：系统=<SYS> | 语言=<LANG> | 特性=<FEAT> | 转换链=<T1-T4 中适用的>
        > **断言源**：ASE-xxx（semantics/assertions.tsv）/ 场景 invariants
        > **环境**：E1/E2；**状态**：pending（→mapped→verified，TEST-13 状态机）
        > **真实执行**：--live 需用户在场（集中批）；平时 dry-run 门禁

        ## Given
        <前置条件：环境/配置/数据——引用 fixtures 与 config-templates 具体文件>

        ## When
        <触发动作：生产/注入故障/配置变更>

        ## Then
        <可判定断言逐条；引用 ASE id 时必须与 assertions.tsv 的 then 一致>

        ## Dry-run 验证
        ```bash
        bash Testing/07-集成矩阵/cases/<sys>/<lang>/<feat>/TC-<...>.sh        # 打印执行计划
        ```

        ## 关联

        <互链：语义矩阵格/运维画像节/对应 02 设计篇/对应 03 落地篇>

```

**写作纪律**：每条 Then 可机判（值/行为/状态三型）；挂账项显式标注；维度值必须与 4 个维度 TSV 的 code 一致。
