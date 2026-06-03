import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.join(__dirname, "..");

const indexPath = path.join(repoRoot, "index.html");
const promptPath = path.join(repoRoot, "prompts", "system_production.md");

const html = fs.readFileSync(indexPath, "utf8");
const prompt = fs.readFileSync(promptPath, "utf8").trim();

const match = html.match(/const SYSTEM_PROMPT = `([\s\S]*?)`;\s*\n\nfunction getChatPayload/);
if (!match) {
  console.error("未在 index.html 中找到 SYSTEM_PROMPT。");
  process.exit(1);
}

const inlinePrompt = match[1].trim();
if (inlinePrompt !== prompt) {
  console.error("SYSTEM_PROMPT 不一致：index.html 与 prompts/system_production.md 未同步。");
  process.exit(1);
}

console.log("SYSTEM_PROMPT 同步检查通过。");
