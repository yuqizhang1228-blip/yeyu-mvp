#!/usr/bin/env node
/**
 * check-prompts.js
 *
 * CI 一致性检查：验证 prompts/*.md 中的提示词正文与 index.html 中的字面量完全一致。
 * 不一致时以非零退出码失败，并打印 diff 摘要。
 *
 * 用法：
 *   node scripts/check-prompts.js
 *   npm run check:prompts
 *
 * 检查项：
 *   1. prompts/system_production.md  ↔  index.html 中 const SYSTEM_PROMPT = `...`
 *   2. prompts/chip_generation.md    ↔  index.html 中 generateChips() 里的 chip system message 模板（去占位符后比对关键片段）
 *   3. prompts/history_title.md      ↔  index.html 中 generateHistoryTitle() 里的 system message
 */

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");

// ── 工具函数 ────────────────────────────────────────────────────────────────

function readFile(relPath) {
  return fs.readFileSync(path.join(ROOT, relPath), "utf8");
}

/**
 * 从 Markdown 文件中提取第一个 ```text ... ``` 代码块的内容。
 */
function extractMdTextBlock(md) {
  const m = md.match(/```text\r?\n([\s\S]*?)```/);
  if (!m) throw new Error("未在 md 文件中找到 ```text...``` 代码块");
  return m[1];
}

/**
 * 规范化字符串用于比较：统一换行符，去除尾部空白。
 */
function normalize(s) {
  return s.replace(/\r\n/g, "\n").trimEnd();
}

/**
 * 输出简单的行级 diff（仅显示前 10 处差异）。
 */
function showDiff(expected, actual, label) {
  const eLines = expected.split("\n");
  const aLines = actual.split("\n");
  const maxLen = Math.max(eLines.length, aLines.length);
  let diffCount = 0;
  console.error(`\n  ── ${label} diff（前10处）──`);
  for (let i = 0; i < maxLen && diffCount < 10; i++) {
    const e = eLines[i] ?? "(行不存在)";
    const a = aLines[i] ?? "(行不存在)";
    if (e !== a) {
      diffCount++;
      console.error(`  第 ${i + 1} 行`);
      console.error(`    md:   ${e.slice(0, 120)}`);
      console.error(`    html: ${a.slice(0, 120)}`);
    }
  }
  if (diffCount === 0) {
    console.error("  （内容相同但存在其他差异，请检查行数）");
    console.error(`  md 行数: ${eLines.length}，html 行数: ${aLines.length}`);
  }
}

// ── 检查 1：SYSTEM_PROMPT ────────────────────────────────────────────────────

function checkSystemPrompt(html) {
  const label = "system_production.md ↔ SYSTEM_PROMPT";
  console.log(`\n[1] 检查 ${label}`);

  // 从 index.html 提取
  const m = html.match(/const SYSTEM_PROMPT = `([\s\S]*?)`;\s*\n/);
  if (!m) throw new Error("未在 index.html 中找到 const SYSTEM_PROMPT = `...`;");
  const fromHtml = normalize(m[1]);

  // 从 md 提取
  const md = readFile("prompts/system_production.md");
  const fromMd = normalize(extractMdTextBlock(md));

  if (fromMd === fromHtml) {
    console.log("  ✓ 一致");
    return true;
  }

  console.error("  ✗ 不一致！");
  showDiff(fromMd, fromHtml, label);
  return false;
}

// ── 检查 2：Chip 生成 system message（关键片段比对）────────────────────────

function checkChipPrompt(html) {
  const label = "chip_generation.md ↔ generateChips() system message";
  console.log(`\n[2] 检查 ${label}`);

  // 从 index.html 提取 chip system message（模板字符串中的固定部分）
  // 找到 chipMessages 数组里的第一个 system content
  const m = html.match(/role:\s*'system',\s*\n\s*content:\s*`([\s\S]*?)`\s*\}\s*\]/);
  if (!m) throw new Error("未在 index.html 中找到 chip system message 模板");
  const fromHtml = normalize(m[1]);

  // 从 md 提取（去掉占位符标记行后取固定文本段落）
  const md = readFile("prompts/chip_generation.md");
  const fromMd = normalize(extractMdTextBlock(md));

  // 将 md 中的占位符替换为 index.html 中实际使用的模板语法，对关键片段比对
  // 选取不含占位符的稳定片段进行比对
  const STABLE_SNIPPETS = [
    "重要：不要用换行符、不要用列表符号",
    "单条总字数含标点请控制在36字以内",
    "只输出JSON数组，恰好5个字符串",
    "不用病理化词汇",
    "五个场景尽量分散",
  ];

  let allOk = true;
  for (const snippet of STABLE_SNIPPETS) {
    const inMd = fromMd.includes(snippet);
    const inHtml = fromHtml.includes(snippet);
    if (!inMd || !inHtml) {
      console.error(`  ✗ 关键片段缺失：「${snippet}」`);
      console.error(`    在 md: ${inMd}，在 html: ${inHtml}`);
      allOk = false;
    }
  }

  if (allOk) {
    console.log("  ✓ 关键片段一致");
  }
  return allOk;
}

// ── 检查 3：历史标题 system message ─────────────────────────────────────────

function checkHistoryTitlePrompt(html) {
  const label = "history_title.md ↔ generateHistoryTitle() system message";
  console.log(`\n[3] 检查 ${label}`);

  // 从 index.html 提取 generateHistoryTitle 中的 system content（单引号字符串）
  const m = html.match(/generateHistoryTitle\(\)[\s\S]*?role:\s*'system',\s*content:\s*'([\s\S]*?)'\s*\}/);
  if (!m) throw new Error("未在 index.html 中找到 generateHistoryTitle() system message");
  const fromHtml = normalize(m[1]);

  // 从 md 提取
  const md = readFile("prompts/history_title.md");
  const fromMd = normalize(extractMdTextBlock(md));

  if (fromMd === fromHtml) {
    console.log("  ✓ 一致");
    return true;
  }

  console.error("  ✗ 不一致！");
  showDiff(fromMd, fromHtml, label);
  return false;
}

// ── 主流程 ───────────────────────────────────────────────────────────────────

function main() {
  console.log("=== 夜屿 Prompt 一致性检查 ===");
  console.log(`项目根目录: ${ROOT}`);

  const html = readFile("index.html");
  let allPassed = true;

  try {
    if (!checkSystemPrompt(html)) allPassed = false;
  } catch (e) {
    console.error(`  [ERROR] ${e.message}`);
    allPassed = false;
  }

  try {
    if (!checkChipPrompt(html)) allPassed = false;
  } catch (e) {
    console.error(`  [ERROR] ${e.message}`);
    allPassed = false;
  }

  try {
    if (!checkHistoryTitlePrompt(html)) allPassed = false;
  } catch (e) {
    console.error(`  [ERROR] ${e.message}`);
    allPassed = false;
  }

  console.log("\n" + "=".repeat(40));
  if (allPassed) {
    console.log("✓ 所有检查通过：prompts/*.md 与 index.html 一致");
    process.exit(0);
  } else {
    console.error("✗ 检查失败：存在不一致，请同步更新 prompts/*.md 或 index.html");
    console.error("  提示：修改 index.html 中的提示词后，必须同步更新对应的 prompts/*.md 文件");
    process.exit(1);
  }
}

main();
