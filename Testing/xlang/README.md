# xlang 跨语言金样本矩阵（批次189 起）

8 业务场景金样本（`Testing/fixtures/generators/`，体例见 `../fixtures/README.md`）在 5 语言 JSON 编码器（Python / Node / Go / Java / Rust）下的交叉验证。

## 两模式

- **project**：用本语言标准 JSON 解析器读输入 JSONL，输出 `{"i":<事件号>, "f":{<点路径>: ["num","<精确字面量>","<语义值>"]}}` 投影（string/bool/null 为 `["str"/"bool"/"null", <值>]`；num 的第二项是解析器看到的**精确字面量**，第三项是语言语义值——两者背离即精度损失证据）。
- **emit**：用本语言默认 JSON 编码器把输入事件重新序列化回 JSONL（round-trip 用）。

## 运行

```
bash topics/scripts/xlang-matrix.sh --validate   # 仅 8 组金样本结构/边界自检
bash topics/scripts/xlang-matrix.sh --live       # 全矩阵实跑（自动取依赖：ensure-lib.sh 取 jackson-core，go build/cargo build/javac 构建客户端）
```

结果落 `results/<日期>/xlang-matrix/`（gitignored；work/ 逐事件投影与逐对 diff 明细）。

## 判定分类（matrix_driver.py）

| 分类 | 语义 | 处置 |
|---|---|---|
| precision_loss | 数值语义值真实改变（如 19 位奇数整数量纲级塌缩） | 缺陷证据 |
| time_offset | 时间类字段 float 重序列化差 | 记录 |
| optionality_collapse | 可选字段在重序列化中消失 | 记录 |
| type_shift | int↔float 类型漂移（非良性精确表示） | 记录 |
| repr_drift | 良性表征差（100 vs 100.0；int 的 float 精确表示） | 无害 |
| infra_error | 构建/依赖/执行失败 | 基础设施问题，非编码器差异 |

精度探针：gen-inventory.py 的 `quantity=10**18+7`（19 位奇数，float64 尾数不可精确表示）；int 语义语言应全程保持字面精确，float64 语义语言（Node JS number）应可观测塌缩为 10^18。
