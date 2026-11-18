# TC-DESIGN-PULSAR-DEDUP-01：dedup 窗口 vs 重试窗

> **维度**：系统=PULSAR | 行为=设计评审（DESIGN） | 断言面：五步论证链（01-89）
> **模型路由**：L1 语义定律 | **判据**：窗口≥重试间隔
> **状态**：pending（评审执行=hermes/人工；记录入 evidence-index）

## Given
- 待评审契约声明（dedup 窗口 vs 重试窗）

## When
- 五步链执行：声明提取→模型路由→参数填充→判据应用→置信定级（01-89 §1.89.1）

## Then
- 三态结论之一：✅ 通过 / ⚠️ 缺参禁生产 / ❌ 判据违背必改
- 评审记录按 01-89 §1.89.4 模板落 evidence-index
- 否决案例参照：窗口 1s<重试 5s 否决

## 关联
- 01-89 构件设计论证模板（规则源）/CONTRACT_DESIGN_SPEC（门禁归属）
