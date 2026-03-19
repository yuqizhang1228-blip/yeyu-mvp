/**
 * Braintrust custom code scorers (TypeScript)
 *
 * Docs: https://braintrust.dev/docs/evaluate/write-scorers.md#score-with-custom-code
 *
 * Each scorer receives: { input, output, expected, metadata }
 * Return: number 0..1 OR { name, score, metadata? }
 *
 * Notes:
 * - We treat `output` as the assistant full text (may include <card>...</card>).
 * - These scorers are deterministic "hard metrics".
 */

type ScorerArgs = {
  input: any;
  output: any;
  expected?: any;
  metadata?: any;
};

function toText(output: any): string {
  if (output == null) return "";
  if (typeof output === "string") return output;
  if (typeof output === "object" && typeof output.text === "string") return output.text;
  return String(output);
}

function extractCardJson(text: string): { raw: string | null; parsed: any | null; error?: string } {
  const m = text.match(/<card>([\s\S]*?)<\/card>/);
  if (!m) return { raw: null, parsed: null };
  const raw = (m[1] || "").trim();
  try {
    const parsed = JSON.parse(raw);
    return { raw, parsed };
  } catch (e: any) {
    return { raw, parsed: null, error: e?.message ? String(e.message) : "JSON.parse failed" };
  }
}

function countQuestions(text: string): number {
  // Chinese question marks and common question patterns
  const qm = (text.match(/[？?]/g) || []).length;
  return qm;
}

const BANNED_PATTERNS: RegExp[] = [
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

export const bannedPhraseRate = ({ output }: ScorerArgs) => {
  const text = toText(output);
  const hits = BANNED_PATTERNS.filter((re) => re.test(text)).map((re) => re.source);
  return {
    name: "banned_phrase",
    score: hits.length === 0 ? 1 : 0,
    metadata: { hits_count: hits.length, hits },
  };
};

export const singleQuestion = ({ output }: ScorerArgs) => {
  const text = toText(output);
  const q = countQuestions(text);
  // Allow 0 or 1 question marks; penalize 2+
  const score = q <= 1 ? 1 : 0;
  return { name: "single_question", score, metadata: { question_marks: q } };
};

export const cardJsonParseable = ({ output }: ScorerArgs) => {
  const text = toText(output);
  const { raw, parsed, error } = extractCardJson(text);
  if (!raw) {
    // If no card, don't penalize by default; treat as null scorer.
    // Change to 0 if you want to enforce always having a card.
    return null;
  }
  return {
    name: "card_json_parseable",
    score: parsed ? 1 : 0,
    metadata: { error: parsed ? null : error ?? "parse failed" },
  };
};

export const cardSchemaValid = ({ output }: ScorerArgs) => {
  const text = toText(output);
  const { raw, parsed } = extractCardJson(text);
  if (!raw) return null;
  if (!parsed || typeof parsed !== "object") return { name: "card_schema_valid", score: 0 };

  const hasThought = typeof parsed.thought === "string" && parsed.thought.trim().length > 0;
  const hasReframe = typeof parsed.reframe === "string" && parsed.reframe.trim().length > 0;
  const actionsOk =
    Array.isArray(parsed.actions) &&
    parsed.actions.length === 2 &&
    parsed.actions.every((a: any) => typeof a === "string" && a.trim().length > 0);

  const score = hasThought && hasReframe && actionsOk ? 1 : 0;
  return {
    name: "card_schema_valid",
    score,
    metadata: { hasThought, hasReframe, actionsOk },
  };
};

function actionSpecificityScore(action: string): number {
  const a = action.trim();
  // naive heuristics: time cue + verb + object-ish
  const timeCue = /(现在|今晚|明天|早上|上午|中午|下午|傍晚|睡前|起床后|周[一二三四五六日天]|\d{1,2}点|\d{1,2}分钟)/.test(a);
  const hasVerb = /(写|发|问|读|列|删|改|约|说|记录|整理|打开|关掉|走|坐|去|做|完成|标出|回复|确认)/.test(a);
  const hasObject = /(给|把|对|向|跟|和|在|对着|关于|那条|这个|那件|消息|需求|反馈|同事|老板|对象|朋友)/.test(a);
  const bannedGeneric = /(好好休息|多运动|和朋友聊聊|照顾好自己|给自己一些时间)/.test(a);
  if (bannedGeneric) return 0;
  const score = (timeCue ? 1 : 0) + (hasVerb ? 1 : 0) + (hasObject ? 1 : 0);
  return score / 3;
}

export const actionsSpecific = ({ output }: ScorerArgs) => {
  const text = toText(output);
  const { raw, parsed } = extractCardJson(text);
  if (!raw) return null;
  if (!parsed || !Array.isArray(parsed.actions)) return { name: "actions_specific", score: 0 };
  const scores = parsed.actions.map((a: any) => (typeof a === "string" ? actionSpecificityScore(a) : 0));
  const avg = scores.length ? scores.reduce((x: number, y: number) => x + y, 0) / scores.length : 0;
  return { name: "actions_specific", score: avg, metadata: { per_action: scores } };
};

export const cardOnlyOnce = ({ output }: ScorerArgs) => {
  const text = toText(output);
  const matches = text.match(/<card>[\s\S]*?<\/card>/g) || [];
  if (matches.length === 0) return null;
  return { name: "card_only_once", score: matches.length === 1 ? 1 : 0, metadata: { count: matches.length } };
};

