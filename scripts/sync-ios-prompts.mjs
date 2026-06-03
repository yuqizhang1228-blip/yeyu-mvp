import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(__dirname, "..");
const srcDir = path.join(repoRoot, "prompts");
const destDir = path.join(repoRoot, "ios", "Yeyu", "Resources", "Prompts");

const files = ["system_production.md", "chip_system.md", "history_title_system.md"];

for (const name of files) {
  const src = path.join(srcDir, name);
  const dest = path.join(destDir, name);
  if (!fs.existsSync(src)) {
    console.error(`缺少 ${src}`);
    process.exit(1);
  }
  fs.copyFileSync(src, dest);
  console.log(`已同步 ${name} → ios bundle`);
}
