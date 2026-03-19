# Braintrust（yeyu_test）本地自动跑分

你将用 Braintrust API（通过 SDK）把一套固定测试集回放跑分，并把 experiment 结果写回 Braintrust。

参考：
- 数据集结构：[`braintrust.dev/docs/annotate/datasets.md`](https://braintrust.dev/docs/annotate/datasets.md)
- 跑评测（Eval）：[`braintrust.dev/docs/evaluate/run-evaluations`](https://braintrust.dev/docs/evaluate/run-evaluations)
- 写 scorers：[`braintrust.dev/docs/evaluate/write-scorers.md`](https://braintrust.dev/docs/evaluate/write-scorers.md)

---

## 1）安装依赖

在项目根目录：

```bash
npm install braintrust
```

---

## 2）设置环境变量（不要写进 git）

建议放到 `.env.local`（已被 `.gitignore` 忽略）：

```bash
BRAINTRUST_API_KEY="你的 braintrust api key"
DEEPSEEK_API_KEY="你的 deepseek api key"
BRAINTRUST_PROJECT="yeyu_test"

# 选择测试集：smoke（快）或 regression（更全面）
# YEYU_SUITE="smoke"

# 可选：只跑前 N 条，用于快速迭代
# YEYU_LIMIT="10"
```

可选：

```bash
BRAINTRUST_EXPERIMENT="yeyu_eval_v3_1_$(date +%Y%m%d_%H%M)"
YEYU_DATASET="braintrust/datasets/yeyu_test_dataset_v1.jsonl"
```

---

## 3）运行自动评测（创建 experiment）

```bash
node evals/yeyu_eval.js
```

脚本会：
- 读取 `index.html` 中的 `SYSTEM_PROMPT`
- 回放 `YEYU_DATASET`（默认 `yeyu_test_dataset_v1.jsonl`）
- 调用 DeepSeek 生成回复
- 跑硬指标 scorers（禁用语/问题数/card 解析/动作具体性等）
- 再调用 DeepSeek 做 LLM Judge（输出 JSON 打分）
- 将结果写回 Braintrust 的 experiment

