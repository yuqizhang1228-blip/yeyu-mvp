import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Load env from .env.local (preferred) then .env
import dotenv from "dotenv";
dotenv.config({ path: path.resolve(process.cwd(), ".env.local"), override: true });
dotenv.config({ path: path.resolve(process.cwd(), ".env"), override: false });

import { Eval, startSpan } from "braintrust";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DASHSCOPE_BASE_URL = (
  process.env.DASHSCOPE_BASE_URL ||
  "https://ws-ejtv8grbnjqdnirb.cn-beijing.maas.aliyuncs.com/compatible-mode/v1"
).replace(/\/$/, "");
const CHAT_URL = `${DASHSCOPE_BASE_URL}/chat/completions`;
const DEFAULT_MODEL = process.env.DASHSCOPE_MODEL || "qwen3-max";

function readJsonl(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");
  return raw
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean)
    .map((l) => JSON.parse(l));
}

function readSystemPrompt(promptPath) {
  const text = fs.readFileSync(promptPath, "utf8").trim();
  if (!text) throw new Error(`提示词文件为空: ${promptPath}`);
  return text;
}

function toText(output) {
  if (output == null) return "";
  if (typeof output === "string") return output;
  if (typeof output === "object" && typeof output.text === "string") return output.text;
  return String(output);
}

function extractCardJson(text) {
  const m = text.match(/<card>([\s\S]*?)<\/card>/);
  if (!m) return { raw: null, parsed: null };
  const raw = (m[1] || "").trim();
  try {
    const parsed = JSON.parse(raw);
    return { raw, parsed };
  } catch (e) {
    return { raw, parsed: null, error: e?.message ? String(e.message) : "JSON.parse failed" };
  }
}

function countQuestions(text) {
  return (text.match(/[？?]/g) || []).length;
}

const BANNED_PATTERNS = [
  /你已经做得很好了/,
  /你已经很勇敢了/,
  /你能来找我聊就说明你很了不起/,
  /我能感受到你的(痛苦|委屈|不容易)/,
  /(这种感觉|这感觉)是(完全)?正常的/,
  /每个人都会有这样的时候/,
  /你值得被好好对待/,
  /你值得更好的/,
  /慢慢来(，|,)?不着急/,
  /给自己一些时间/,
  /这不是你的错/,
  /我理解你/,
  /别想太多/,
  /一切都会好的/,
  /加油/,
  /抱抱/,
  /你真的很棒/,
];

// ---- Hard scorers (0..1) ----
const bannedPhraseScore = ({ output }) => {
  const text = toText(output);
  const hits = BANNED_PATTERNS.filter((re) => re.test(text)).map((re) => re.source);
  return { name: "禁用语（命中=0）", score: hits.length === 0 ? 1 : 0, metadata: { hits } };
};

const singleQuestionScore = ({ output }) => {
  const text = toText(output);
  const q = countQuestions(text);
  return { name: "单问题约束（≤1问号）", score: q <= 1 ? 1 : 0, metadata: { question_marks: q } };
};

const cardJsonParseableScore = ({ output, expected }) => {
  const text = toText(output);
  const { raw, parsed, error } = extractCardJson(text);
  const required = expected && expected.card_required === true;
  if (!raw) return required ? { name: "卡片JSON可解析", score: 0, metadata: { error: "missing_card" } } : null;
  return { name: "卡片JSON可解析", score: parsed ? 1 : 0, metadata: { error: parsed ? null : error } };
};

const cardSchemaValidScore = ({ output, expected }) => {
  const text = toText(output);
  const { raw, parsed } = extractCardJson(text);
  const required = expected && expected.card_required === true;
  if (!raw) return required ? { name: "卡片结构完整（thought/reframe/actions）", score: 0, metadata: { reason: "missing_card" } } : null;
  if (!parsed || typeof parsed !== "object") return { name: "卡片结构完整（thought/reframe/actions）", score: 0 };
  const hasThought = typeof parsed.thought === "string" && parsed.thought.trim().length > 0;
  const hasReframe = typeof parsed.reframe === "string" && parsed.reframe.trim().length > 0;
  const actionsOk =
    Array.isArray(parsed.actions) &&
    parsed.actions.length === 2 &&
    parsed.actions.every((a) => typeof a === "string" && a.trim().length > 0);
  return { name: "卡片结构完整（thought/reframe/actions）", score: hasThought && hasReframe && actionsOk ? 1 : 0, metadata: { hasThought, hasReframe, actionsOk } };
};

function actionSpecificityScore(action) {
  const a = String(action || "").trim();
  const timeCue = /(现在|今晚|明天|早上|上午|中午|下午|傍晚|睡前|起床后|周[一二三四五六日天]|\d{1,2}点|\d{1,2}分钟)/.test(a);
  const hasVerb = /(写|发|问|读|列|删|改|约|说|记录|整理|打开|关掉|走|坐|去|做|完成|标出|回复|确认)/.test(a);
  const hasObject = /(给|把|对|向|跟|和|在|对着|关于|那条|这个|那件|消息|需求|反馈|同事|老板|对象|朋友)/.test(a);
  const bannedGeneric = /(好好休息|多运动|和朋友聊聊|照顾好自己|给自己一些时间)/.test(a);
  if (bannedGeneric) return 0;
  const score = (timeCue ? 1 : 0) + (hasVerb ? 1 : 0) + (hasObject ? 1 : 0);
  return score / 3;
}

const actionsSpecificScore = ({ output, expected }) => {
  const text = toText(output);
  const { raw, parsed } = extractCardJson(text);
  const required = expected && expected.card_required === true;
  if (!raw) return required ? { name: "行动具体性（时间+对象+动作）", score: 0, metadata: { reason: "missing_card" } } : null;
  if (!parsed || !Array.isArray(parsed.actions)) return { name: "行动具体性（时间+对象+动作）", score: 0 };
  const per = parsed.actions.map((a) => actionSpecificityScore(a));
  const avg = per.length ? per.reduce((x, y) => x + y, 0) / per.length : 0;
  return { name: "行动具体性（时间+对象+动作）", score: avg, metadata: { per_action: per } };
};

const cardOnlyOnceScore = ({ output, expected }) => {
  const text = toText(output);
  const matches = text.match(/<card>[\s\S]*?<\/card>/g) || [];
  const required = expected && expected.card_required === true;
  if (matches.length === 0) return required ? { name: "卡片仅出现一次", score: 0, metadata: { reason: "missing_card" } } : null;
  return { name: "卡片仅出现一次", score: matches.length === 1 ? 1 : 0, metadata: { count: matches.length } };
};

// ---- LLM Judge scorer (通义千问) ----
function buildJudgePrompt(outputText) {
  return `你是一个严格但公平的评审。你要评估“夜屿（夜屿小岛守夜人）”这条回复的质量。\n只评估 assistant 输出本身，不要脑补用户其他信息。\n\n你只需要评估两件事：\n1) 人感：是否像冷静成熟、可信赖的人，而不是客服/模板/说明书。\n2) 推进质量：是否有一个自然、具体、不过度逼迫的推进（通常是一个问题；如果不适合提问，也要有合理承接）。\n\n【硬性扣分雷区】出现任意一条，等级最多只能给 C：\n- 鸡汤/空话（如“你已经做得很好了”“一切都会好的”“加油”“抱抱”等）\n- 连问两个或以上问题（多个问号/多个问题句）\n- 明显模板化套话（泛泛共情 + 泛泛追问）\n\n请在 A/B/C/D 四个等级中选一个：\n- A：非常像人 + 推进自然具体\n- B：整体不错，但略模板/推进略弱\n- C：人感弱或推进不自然（或触发扣分雷区）\n- D：明显不合格（强模板/强鸡汤/强连问/不推进）\n\n输出格式：只输出一个 JSON（不要任何额外文字）：\n{\n  \"grade\": \"A|B|C|D\",\n  \"reasons\": [\n    \"引用 assistant 输出中的一个具体片段作为证据\",\n    \"再引用一个具体片段作为证据\"\n  ]\n}\n\nassistant 输出：\n---\n${outputText}\n---\n`;
}

async function dashscopeChat({ apiKey, messages, temperature = 0.7, top_p = 0.9, max_tokens = 500, model = DEFAULT_MODEL }) {
  const resp = await fetch(CHAT_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
    body: JSON.stringify({ model, temperature, top_p, max_tokens, messages }),
  });
  const data = await resp.json();
  if (!resp.ok) {
    const msg = data?.error?.message || data?.error || `DashScope ${resp.status}`;
    throw new Error(msg);
  }
  return data?.choices?.[0]?.message?.content ?? "";
}

const llmJudgeScore = async ({ output }) => {
  const apiKey = (process.env.DASHSCOPE_API_KEY || "").trim();
  if (!apiKey) return null;
  const out = toText(output).slice(0, 6000); // avoid runaway cost
  const judge = await dashscopeChat({
    apiKey,
    temperature: 0,
    top_p: 1,
    max_tokens: 400,
    messages: [{ role: "system", content: "你是评审，请严格按要求输出 JSON。" }, { role: "user", content: buildJudgePrompt(out) }],
  });
  let parsed = null;
  try {
    parsed = JSON.parse(judge);
  } catch {
    // try to salvage JSON inside
    const m = judge.match(/\{[\s\S]*\}/);
    if (m) {
      try {
        parsed = JSON.parse(m[0]);
      } catch {}
    }
  }
  if (!parsed || typeof parsed !== "object") {
    return { name: "主观评审（LLM Judge）", score: 0, metadata: { raw: judge.slice(0, 400) } };
  }
  const grade = typeof parsed.grade === "string" ? parsed.grade.trim().toUpperCase() : "";
  const gradeToScore = { A: 1, B: 0.75, C: 0.4, D: 0 };
  const score = gradeToScore[grade] ?? 0;
  return {
    name: "主观评审（LLM Judge）",
    score: Math.max(0, Math.min(1, score)),
    metadata: { grade, reasons: parsed.reasons },
  };
};

// ---- Task: call 通义千问 with our messages ----
async function taskFn(input) {
  const apiKey = (process.env.DASHSCOPE_API_KEY || "").trim();
  if (!apiKey) throw new Error("DASHSCOPE_API_KEY 未设置");

  const systemPrompt = readSystemPrompt(path.join(__dirname, "..", "prompts", "system_production.md"));
  const timeInfo = "【当前时间】现在是深夜（适合更轻更静的语气，行动建议避免打电话）";

  const userTurns = Array.isArray(input?.thread)
    ? input.thread
    : [{ role: "user", content: input?.user ?? "" }];

  // Trace: one case -> one root span; each user turn -> one child span
  const caseId = typeof input?.case_id === "string" ? input.case_id : "unknown_case";
  const rootSpan = startSpan({
    name: `case:${caseId}`,
    event: {
      input: { case_id: caseId, thread: userTurns },
    },
  });

  const history = [
    { role: "system", content: systemPrompt },
    { role: "system", content: timeInfo },
  ];

  let lastAssistant = "";
  const assistantTurns = [];
  const startMs = Date.now();

  try {
    for (let i = 0; i < userTurns.length; i++) {
      const turn = userTurns[i];
      if (!turn || turn.role !== "user") continue;

      const turnSpan = rootSpan.startSpan({
        name: `turn_${i + 1}`,
        event: {
          input: { role: "user", content: String(turn.content ?? "") },
          metadata: { turn_index: i + 1 },
        },
      });

      const t0 = Date.now();
      try {
        history.push({ role: "user", content: String(turn.content ?? "") });
        lastAssistant = await dashscopeChat({ apiKey, messages: history });
        history.push({ role: "assistant", content: lastAssistant });
        assistantTurns.push({ role: "assistant", content: lastAssistant });

        turnSpan.log({
          output: lastAssistant,
          metadata: { duration_ms: Date.now() - t0 },
        });
      } catch (e) {
        turnSpan.log({
          error: String(e?.message ?? e),
          metadata: { duration_ms: Date.now() - t0 },
        });
        throw e;
      } finally {
        turnSpan.end();
      }
    }

    rootSpan.log({
      output: lastAssistant,
      metadata: {
        total_turns: userTurns.length,
        duration_ms: Date.now() - startMs,
        assistant_turns: assistantTurns,
      },
    });
  } finally {
    rootSpan.end();
  }

  return lastAssistant;
}

async function main() {
  const project = process.env.BRAINTRUST_PROJECT || "yeyu_test";
  const experimentName =
    process.env.BRAINTRUST_EXPERIMENT ||
    `yeyu_eval_${new Date().toISOString().slice(0, 16).replace(/[:-]/g, "")}`;

  // Debug (safe): show presence/length only, never print secrets
  const btKeyLen = (process.env.BRAINTRUST_API_KEY ? String(process.env.BRAINTRUST_API_KEY) : "").trim().length;
  const dsKeyLen = (process.env.DASHSCOPE_API_KEY ? String(process.env.DASHSCOPE_API_KEY) : "").trim().length;
  console.log(`[env] BRAINTRUST_API_KEY length: ${btKeyLen}`);
  console.log(`[env] DASHSCOPE_API_KEY length: ${dsKeyLen}`);

  if (!process.env.BRAINTRUST_API_KEY || !String(process.env.BRAINTRUST_API_KEY).trim()) {
    throw new Error("BRAINTRUST_API_KEY 未设置：请在项目根目录的 .env.local 中设置");
  }
  if (!process.env.DASHSCOPE_API_KEY || !String(process.env.DASHSCOPE_API_KEY).trim()) {
    throw new Error("DASHSCOPE_API_KEY 未设置：请在项目根目录的 .env.local 中设置");
  }

  const datasetPath =
    process.env.YEYU_DATASET ||
    (() => {
      const suite = (process.env.YEYU_SUITE || "smoke").toLowerCase();
      if (suite === "regression") {
        return path.join(__dirname, "..", "braintrust", "datasets", "yeyu_regression.jsonl");
      }
      return path.join(__dirname, "..", "braintrust", "datasets", "yeyu_smoke.jsonl");
    })();

  const limit = Number.parseInt(process.env.YEYU_LIMIT || "", 10);
  const records = readJsonl(datasetPath);
  const selected = Number.isFinite(limit) && limit > 0 ? records.slice(0, limit) : records;

  const data = selected.map((r) => ({
    input: { ...r.input, case_id: r.id },
    expected: r.expected,
    metadata: r.metadata,
  }));

  Eval(project, {
    experimentName,
    data,
    task: taskFn,
    scores: [
      bannedPhraseScore,
      singleQuestionScore,
      cardJsonParseableScore,
      cardSchemaValidScore,
      actionsSpecificScore,
      cardOnlyOnceScore,
      llmJudgeScore,
    ],
    metadata: {
      model: DEFAULT_MODEL,
      prompt_source: "prompts/system_production.md",
      dataset: path.basename(datasetPath),
    },
  });
}

main();

