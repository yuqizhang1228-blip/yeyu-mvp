# iOS 视觉策略 · P0 与 0515 收口

> **决策（2026-06-02）**：P0 仍以 **功能验收** 为准；整体 UI 已切到 Figma **0515**（`cGFZXtYVmzWIQ7XqybecGP`），与现实现差异大。工程上 **不挡后续大改版**，只做最小 Token 对齐 + 语义预留。

## P0（当前）

| 做 | 不做 |
|----|------|
| Epic 主路径（`P0_ACCEPTANCE.md`） | 首页横向 Chip、背景插画、玻璃输入框 |
| 危机 / 出卡 / 三选一等交互 | 与 0515 逐屏像素一致 |
| **左侧抽屉** | **功能冻结**（见 [`DRAWER_SCOPE.md`](./DRAWER_SCOPE.md)）；仅视觉可对齐 `226:2399` |
| 色板/圆角 **轻量** 向 0515 靠拢（见 `YeyuDesignTokens` 0515 段） | 在 View 里写死 hex |
| 首页底部 **合规一行**（与稿一致，非装饰） | 重写 `HomeView` 信息架构 |

**实现约定**

- 视图只引用 **`YeyuColor` / `YeyuRadius` / `YeyuSpacing`**；新稿色值先进 Token，再按需替换引用。
- 0515 专用名以 `surfacePromptCard`、`radiusPromptCard` 等 **语义名** 登记；P0 仅在少数组件使用，其余保留给 v1.1。
- 布局/文案大改：对照 [`FIGMA_LINEAR_SYNC.md`](../design-system/夜屿-night-isle/FIGMA_LINEAR_SYNC.md) §8，单开 **视觉收口** 里程碑（建议 Linear 标签 `ios-visual-0515`）。

## v1.1+ 视觉收口（建议顺序）

1. **Token 统一**：`backgroundBase` 等 P0 别名切到 0515 主色（或保留 legacy 别名一层）。
2. **YUQ-27 首页**：背景图、问候 copy、横向 Chip、`input box`（模型/语音 icon）。
3. **YUQ-32 聊天**：胶囊用户气泡、流式/思考条（与 YUQ-47 工程票合并规划）。
4. **YUQ-40 / 33**：出卡弹窗、三选一 — 按 Linear 附件 node 逐屏。
5. **YUQ-30**：**仅抽屉面板视觉**；入口/列表行为仍以 `DRAWER_SCOPE.md` 为准。
5. **设置系**（34/37/38/39）：子页与 H5 免责对齐。

## 单一真相源

| 类型 | 位置 |
|------|------|
| Figma node ↔ Issue | `design-system/夜屿-night-isle/FIGMA_LINEAR_SYNC.md` |
| UX 裁决 | `design-system/夜屿-night-isle/MASTER.md` |
| 代码 Token | `ios/Yeyu/Design/YeyuDesignTokens.swift` |
