# AI Agent 指南（夜屿 / yeyu-mvp）

> 供 Cursor、Claude Code、Copilot 等任意编码助手使用。**以本文件为入口**，避免误走已归档技术栈。

## 先读什么（按顺序）

| 优先级 | 文件 | 用途 |
|--------|------|------|
| 1 | [`.cursor/rules/yeyu-project.mdc`](./.cursor/rules/yeyu-project.mdc) | **硬性规范**（栈、禁区、Prompt、安全边界） |
| 2 | [`MONOREPO.md`](./MONOREPO.md) | 目录与命令单一入口 |
| 3 | [`CONTEXT.md`](./CONTEXT.md) | 产品史、关键决策、待办 |
| 4 | [`design-system/夜屿-night-isle/MASTER.md`](./design-system/夜屿-night-isle/MASTER.md) | UI/UX 裁决（改界面必读） |
| 5 | [`ios/P0_ACCEPTANCE.md`](./ios/P0_ACCEPTANCE.md) | iOS v1 范围与验收（**勿扩 P0 外需求**） |

改 **SYSTEM_PROMPT** 时另读 [`PROMPT_HISTORY.md`](./PROMPT_HISTORY.md)，并运行 `npm run prompt:check` + `npm run prompt:sync-ios`。

## 稳定技术栈（勿擅自更换）

| 层 | 选型 | 路径 |
|----|------|------|
| H5 验证 | 单文件 HTML/CSS/JS | `index.html` |
| iOS 客户端 | **SwiftUI + SwiftData**（iOS 17+） | `ios/` |
| API | Vercel / Express 代理 DeepSeek | `api/chat.js` |
| Prompt 源 | Markdown 归档 | `prompts/` → iOS Bundle |
| 评测 | Braintrust eval | `evals/` |

**已归档、禁止作为主工程开发**：`mobile/`（React Native 试验稿，见 `mobile/ARCHIVED.md`）。

## 稳定产品方向（v1）

- **定位**：基于 CBT 理念的 AI 情绪梳理；4 阶段对话（接住→探针→松动→收束）→ **行动卡片**（`thought` / `reframe` / `actions`）。
- **视觉**：深色 OLED 夜间气质；实现以 **Design Token** 为准（`YeyuDesignTokens` / `index.html` CSS 变量 / `MASTER.md`），**v1 不做 Figma 像素级还原**（设计轨并行）。
- **安全**：危机词触发 **400-161-9995**，逻辑不可删改。
- **沟通**：与产品负责人 YUQI 使用**简体中文**。

## 常见误操作（禁止）

- 在 `mobile/` 继续堆 RN 功能或引入 Expo。
- 给 H5 默认加 React/Vue/Tailwind 运行时。
- 改 Prompt 不同步 `prompts/`、`PROMPT_HISTORY.md` 与 iOS Bundle。
- 删除或重命名 H5 `localStorage` 键：`yeyu_cards` / `yeyu_history` / `yeyu_username` / `yeyu_uid`。
- 无版本计划地改 SwiftData 模型（见 `SwiftDataBootstrap` 的 store 名 bump 约定）。

## 与 Cursor 的关系

Cursor 会自动加载 `.cursor/rules/yeyu-project.mdc`（`alwaysApply: true`）。其它助手无 Cursor 时，**视本文件 + `yeyu-project.mdc` 内容为同等约束**。
