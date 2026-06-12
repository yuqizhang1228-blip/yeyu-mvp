# 夜屿 Monorepo 说明（单一仓库入口）

> **判断成本最小化**：只 clone / 只打开 **`yeyu-mvp`** 这一仓。H5、API、Prompt、评测、iOS 都在下面。  
> **AI 助手入口**：[`AGENTS.md`](./AGENTS.md) · [`CLAUDE.md`](./CLAUDE.md) · [`.cursor/rules/yeyu-project.mdc`](./.cursor/rules/yeyu-project.mdc)

## 目录一览

| 路径 | 是什么 | 怎么跑 |
|------|--------|--------|
| **`index.html`** | H5 单页 MVP（当前线上验证） | 根目录 `npm run dev` → http://localhost:3000 |
| **`api/`** + **`server.js`** | 通义千问代理（Vercel / 本地共用） | 随 `npm run dev` |
| **`prompts/`** | 提示词：`system_production.md`、`chip_system.md`、`history_title_system.md`；契约见 `API_CHAT.md` | `npm run prompt:check`；改 prompt 后 `npm run prompt:sync-ios` |
| **`evals/`** + **`braintrust/`** | 提示词回归评测 | `npm run eval:yeyu` |
| **`ios/`** | **SwiftUI 原生 iOS App**（Linear 端改造一期） | `open ios/Yeyu.xcodeproj` |
| **`mobile/`** | ⚠️ RN 试验稿（**已归档**，见 `mobile/ARCHIVED.md`） | 勿用 |
| **`design-system/`** | UI 决策源（MASTER）+ [Figma↔Linear 对照](design-system/夜屿-night-isle/FIGMA_LINEAR_SYNC.md) | 设计对照 |

## 命令速查

```bash
# H5 + 本地 API
npm install
export DASHSCOPE_API_KEY="..."
npm run dev

# iOS（SwiftUI）
open ios/Yeyu.xcodeproj
# Xcode → 选模拟器 → ⌘R
```

## 与 Linear 的对应关系

| Linear 项目 | 代码在哪 |
|-------------|----------|
| 夜屿 UI UX 精益设计（YUQ-27～40） | Figma + 实现在 **`ios/`** 或 **`index.html`** |
| 端改造一期 / iOS v1（YUQ-41～50） | **`ios/`** + 根目录 Prompt/API |

## 技术栈

- **H5**：纯 HTML/CSS/JS → Vercel
- **iOS**：**SwiftUI + SwiftData**（`ios/`，iOS 17+）
- **AI**：App 走 **`https://yeyu-mvp.vercel.app/api/chat`**，Key 不进客户端（YUQ-42）

## 决策记录

- **2026-06-02**：正式选定 **SwiftUI 原生**（路线 B）；`mobile/` RN 归档，不再维护。
