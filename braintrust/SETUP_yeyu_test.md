# Braintrust 配置指南（Project: yeyu_test）

> 目标：用 Braintrust 在网页端**自动回放对话测试集**，并用「硬指标 + LLM Judge」持续跑分，对比不同提示词版本的质量变化。
>
> 参考 Braintrust 官方工作流：Instrument → Observe → Annotate → Evaluate → Deploy（见：[`braintrust.dev/docs/workflow`](https://www.braintrust.dev/docs/workflow)）

---

## 你将导入哪些文件

- **Dataset（JSONL）**：`braintrust/datasets/yeyu_test_dataset_v1.jsonl`
- **硬指标 scorers（自定义代码）**：`braintrust/scorers/yeyu_hard_scorers.ts`
- **LLM Judge 提示词（UI 里创建）**：`braintrust/judges/yeyu_llm_judge_prompt.md`

Dataset 结构遵循 Braintrust 的标准：每条记录包含 `input`（必填）、可选 `metadata`/`expected`（见：[`braintrust.dev/docs/annotate/datasets.md`](https://braintrust.dev/docs/annotate/datasets.md)）

---

## Step 0：在代码侧准备“版本号”

在夜屿项目里，建议你保持一个显式版本号（用于对比 & 回归定位），例如：
- `v3.0`：结构化压缩 + prompt caching
- `v3.1`：守夜人设定 + 问身份话术

在 Braintrust 里我们会把它作为 `metadata.prompt_version`（以及 experiment metadata）写进去。

---

## Step 1：创建 Project

在 Braintrust 网页端：
- 新建 Project，名称填：`yeyu_test`

---

## Step 2：导入 Dataset

进入 `Datasets`：
- 点击 `+ Dataset` / `Upload CSV/JSON`
- 上传：`braintrust/datasets/yeyu_test_dataset_v1.jsonl`

映射建议（拖拽列到对应分类）：
- `id` → **Input**（Braintrust 会用于去重）
- `input.*` → **Input**
- `metadata.*` → **Metadata**
- `expected.*` → **Expected**

导入后，你会看到每条测试用例可按 `metadata.scene`、`metadata.case_type` 等字段筛选。

---

## Step 3：创建 Evaluation / Experiment（跑分）

在 `Evaluate` 或 `Experiments` 页面（不同 UI 版本入口略有差异）：

1. 选择数据源：刚导入的 dataset
2. 配置 task（模型调用）：
   - **系统提示词**：粘贴你要测的版本（例如 v3.0 或 v3.1）
   - **用户输入**：用 dataset 的 `input.thread`（多轮）或 `input.user`（单轮）
3. 运行两次形成对比：
   - Experiment A：`prompt_version=v3.0`
   - Experiment B：`prompt_version=v3.1`

建议固定以下参数，减少变量：
- model：与你线上一致（DeepSeek-V3 / deepseek-chat）
- temperature：0.7
- top_p：0.9
- max_tokens：500

---

## Step 4：添加硬指标 scorers（Custom code）

Braintrust 支持自定义代码 scorer（TS/Python），scorer 会收到 `{ input, output, expected, metadata }`，返回 `0~1` 或 `{ score, metadata }`（见：[`braintrust.dev/docs/evaluate/write-scorers.md`](https://braintrust.dev/docs/evaluate/write-scorers.md)）。

在网页端创建 scorers 时，把 `braintrust/scorers/yeyu_hard_scorers.ts` 里的函数逐个粘贴进去即可（每个 scorer 一个）。

---

## Step 5：添加 LLM-as-judge scorer（主观指标）

在 UI 里创建一个 LLM Judge scorer（span/trace 级别都可）：
- 推荐 scope：**Span**（对单条输出打分更直观）
- Prompt 模板：粘贴 `braintrust/judges/yeyu_llm_judge_prompt.md`
- 输出映射：把 judge 的选择映射到 0~1（Braintrust UI 有 Choice scores）

建议你先跑 1~2 次小规模实验，确认 judge 不会被“卡片 JSON/标签”误导。

---

## Step 6：看结果，找“回归样本”

你会得到：
- 总分对比（v3.0 vs v3.1）
- 每个 scorer 的分布
- “最差样本 TOP N”

下一步优化提示词时，优先看：
- 禁用语命中样本
- actions 不够具体的样本
- judge 认为“模板感强/不贴合”的样本

