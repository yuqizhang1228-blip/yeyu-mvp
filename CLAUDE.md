# Claude Code 项目说明（夜屿）

本仓库与 Cursor 共用同一套规范，**不要**把 `mobile/` 当作主工程。

## 权威文档

- **规则（必读）**：`.cursor/rules/yeyu-project.mdc`
- **仓库地图**：`MONOREPO.md`
- **长期上下文**：`CONTEXT.md`
- **设计裁决**：`design-system/夜屿-night-isle/MASTER.md`
- **iOS v1 边界**：`ios/P0_ACCEPTANCE.md`

通用 Agent 入口见根目录 [`AGENTS.md`](./AGENTS.md)。

## 你应扮演的角色

全栈产品工程师：**H5 提示词验证** + **`ios/` SwiftUI 功能迭代**。服务产品负责人 YUQI；回复使用简体中文。

## 技术栈（冻结至 v1 验收后另议）

```
H5:     index.html（零框架 SPA）
iOS:    ios/Yeyu（SwiftUI + SwiftData，API → yeyu-mvp.vercel.app/api/chat）
Prompt: prompts/*.md（npm run prompt:check && prompt:sync-ios）
勿用:   mobile/（RN 已归档）
```

## UI 工作方式

1. 改 UI 前先读 `MASTER.md`；需要时用用户级技能 UI UX Pro Max 做检索（路径见 `yeyu-project.mdc`）。
2. **H5**：只动 `index.html` 内 CSS 变量与语义结构，不引入组件库。
3. **iOS**：只用 `YeyuDesignTokens`，不硬编码 Hex；不追求 Figma 1:1。

## Prompt 变更流程

1. 编辑 `prompts/system_production.md`（及必要时 `chip_system.md` / `history_title_system.md`）。
2. 在 `PROMPT_HISTORY.md` 记录原因与版本号。
3. 同步 H5 内联 `SYSTEM_PROMPT`（与 md 一致）。
4. 运行 `npm run prompt:check` 与 `npm run prompt:sync-ios`。

## 数据与安全

- H5：`localStorage` 键名保持稳定（见 `yeyu-project.mdc`）。
- iOS：SwiftData store 名由 `SwiftDataBootstrap` 管理；模型字段变更需 bump store 或写迁移。
- 危机检测与热线 **400-161-9995** 不可削弱。

## 当前阶段（2026-06）

- H5：线上验证 + Prompt 精调。
- iOS：端改造一期 **P0 已实装**（见 `ios/P0_ACCEPTANCE.md`），待产品统一验收；**非 P0**（SSE、7 字段卡片、CBT 四问、TestFlight）勿提前实现。
