# 夜屿 iOS（SwiftUI 原生）

Linear **端改造一期 · iOS v1** 的工程主目录。与 H5 共用根目录 `api/`、`prompts/`。

**P0 验收**：见 [P0_ACCEPTANCE.md](./P0_ACCEPTANCE.md)

## 要求

- Xcode 15+
- iOS 17+（SwiftData）
- macOS + Apple 开发者账号（TestFlight 见 YUQ-49）

## 打开与运行

```bash
open ios/Yeyu.xcodeproj
# Xcode：选 iPhone 模拟器 → ⌘R
```

API 默认指向生产代理：`https://yeyu-mvp.vercel.app/api/chat`（Key 仅在服务端）。

本地联调 H5 API 时，在 `ChatAPIClient.swift` 将 `baseURL` 改为 Mac 局域网 IP + 根目录 `npm run dev` 端口。

## 目录

```
ios/Yeyu/
├── YeyuApp.swift
├── App/RootView.swift
├── Design/YeyuDesignTokens.swift
├── Models/                 # ChatSession、MemoryCard、CardParser
├── Services/               # ChatAPIClient、Chip、Crisis、Prompt、HistoryTitle
├── Store/                  # AppState、YeyuUser
└── Views/                  # Home（含 NameSetup）、Chat、History、Settings
```

## Prompt 资源

Bundle 内 `Resources/Prompts/`：

- `system_production.md`
- `chip_system.md`
- `history_title_system.md`

根目录 `prompts/` 为单一来源，改主对话 prompt 后运行 `npm run prompt:check` 并同步复制到 `ios/Yeyu/Resources/Prompts/`。

## Linear 对照

| Issue | 实现 |
|-------|------|
| YUQ-43 脚手架 + Token | 本目录 + `YeyuDesignTokens`（含 0515 预留） |
| 视觉 P0 / 收口 | [`VISUAL_ROADMAP.md`](./VISUAL_ROADMAP.md) |
| YUQ-42 Prompt/API | `../prompts/` + `PromptLoader` |
| YUQ-44 出卡确认 | `ActionCardSheet`、`CardBarView` |
| YUQ-45 历史续聊 | SwiftData + `SideDrawerView`（范围 [`DRAWER_SCOPE.md`](./DRAWER_SCOPE.md)）+ 顶栏「+」 |
| YUQ-46 三选一 | `ChoiceGuideView` |
| YUQ-48 主流程 | `NameSetupView`、错误重试、行动卡片列表 |

旧 RN 代码在 **`../mobile/`**（已归档，见 `ARCHIVED.md`）。
