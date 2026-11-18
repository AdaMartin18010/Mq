# TC-DESIGN-KAFKA-RETENTION-01：retention 覆盖最大恢复窗口

> **维度**：系统=KAFKA | 行为=设计评审（DESIGN） | 断言面：五步论证链（01-89）
> **模型路由**：耐久阶梯 | **判据**：保留≥回放窗+安全垫
> **状态**：pending（评审执行=hermes/人工；记录入 evidence-index）

## Given
- 待评审契约声明（retention 覆盖最大恢复窗口）

## When
- 五步链执行：声明提取→模型路由→参数填充→判据应用→置信定级（01-89 §1.89.1）

## Then
- 三态结论之一：✅ 通过 / ⚠️ 缺参禁生产 / ❌ 判据违背必改
- 评审记录按 01-89 §1.89.4 模板落 evidence-index
- 否决案例参照：CDC 30 天回放遇 7 天保留否决

## 关联
- 01-89 构件设计论证模板（规则源）/CONTRACT_DESIGN_SPEC（门禁归属）
