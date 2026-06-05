# 端改造一期 · P0 验收清单

在 Xcode 打开 `ios/Yeyu.xcodeproj`，选 **iPhone 17**（或任意模拟器）→ **⌘R**。  
API 默认：`https://yeyu-mvp.vercel.app/api/chat`（需网络）。

> **说明**：若曾安装过无 `choiceGuideCompleted` 字段的旧包，首次升级可能使用新数据库 `YeyuStore_v2`（本地对话/卡片需重新产生）。模拟器可 **Delete App** 后重装，最干净。

## 视觉边界（P0）

- **功能先行**：下表主路径为验收标准；Figma **0515** 大改版 **不挡 P0**。
- **最小对齐**：色/圆角走 `YeyuDesignTokens`（含 0515 预留语义）；首页 Chip 与合规文案已向稿轻量靠拢。
- **后续收口**：布局/插画/输入区结构等见 [`VISUAL_ROADMAP.md`](./VISUAL_ROADMAP.md) 与 [`FIGMA_LINEAR_SYNC.md`](../design-system/夜屿-night-isle/FIGMA_LINEAR_SYNC.md)。

## Epic 主路径

| # | 步骤 | 预期 |
|---|------|------|
| 1 | 首次安装 / 清除数据后打开 App | 首页显示昵称设置（可跳过） |
| 2 | 设置昵称或跳过 | 出现 Chip + 输入框；跳过后问候不带名字 |
| 3 | 点 Chip 或输入进入对话 | AI 回复；首轮后出现 **三选一** |
| 4 | 选三选一或自行输入第二轮 | 三选一消失且续聊不再出现 |
| 5 | 多轮后 AI 出 `<card>` | 弹出确认 sheet：保存 / 继续聊 / 放弃 |
| 6 | 保存卡片 | 输入框上方出现 **卡片条**；占位「还有什么想聊的…」 |
| 7 | 抽屉 → **行动卡片** | 列表展示已保存卡片；点进可看详情 |
| 8 | 详情 → **回到这场对话** | 回到对应对话且卡片条仍在 |
| 9 | 对话顶栏 **+** | 旧会话归档标题（AI）；进入新空白对话 |
| 10 | 抽屉 **最近对话** | 可切换会话；当前会话高亮（抽屉仅「行动卡片/设置/最近对话」，见 [`DRAWER_SCOPE.md`](./DRAWER_SCOPE.md)） |
| 11 | 输入含危机词 | 弹出危机 sheet（400-161-9995） |
| 12 | 断网或 API 失败 | 错误气泡 + **重试** |
| 13 | 设置 → 清除所有数据 | 对话/卡片/昵称清空 |

## Linear 对照

| Issue | P0 范围 | 状态 |
|-------|---------|------|
| YUQ-42 | `prompts/*` + iOS Bundle + `API_CHAT.md` + `npm run prompt:check` | ✅ |
| YUQ-43 | SwiftUI 工程 + Design Tokens | ✅ |
| YUQ-44 | 出卡确认 + 卡片条 + 续聊 | ✅ |
| YUQ-45 | SwiftData 会话 + 抽屉续聊 + 新建 + AI 标题 | ✅ |
| YUQ-46 | `ChoiceGuideView` + 每会话仅一次 | ✅ |
| YUQ-48 | 昵称首访 + 设置 + 历史详情 + 错误重试 | ✅ |
| YUQ-50 | `MONOREPO.md` + `ios/` 主工程 | ✅ |

## 端打磨增量（P0 后 · 2026-06-05）

> 非 P0，P0 主流程通过后的体验打磨与上架资产；状态 In Review（代码 done + 模拟器验证，待产品验收）。

| Issue | 范围 | 状态 |
|-------|------|------|
| YUQ-53 | 返回键不压状态栏 + 键盘换行键 + 输入热区扩大 + 「+」加照片本地 OCR + 语音 toast + 首页快捷卡骨架加载态 | 🔶 In Review |
| YUQ-54 | 上架资产·合规：App 图标 1024 + `PrivacyInfo.xcprivacy`（UserDefaults·CA92.1）+ 相机权限说明 | 🔶 In Review |
| YUQ-35 | AI 思考态 loading 图标改用设计稿矢量（`ThinkingMountain` 226:2669） | 🔶 In Review |
| YUQ-55 | 记忆增强：LLM 调和（语义去重 + 事实更新/合并）+ 实时「已加入记忆」toast + 手动增改 | 🔶 In Review |

## 明确不在 P0（v1.1+）

- SSE 流式（YUQ-47）
- Chip 本地记忆摘要（H5 `getProfileSummaryForChips`）
- TestFlight / 合规包（YUQ-49）
- **0515 视觉收口**（首页背景/横向 Chip/玻璃输入框等，见 `VISUAL_ROADMAP.md`）
- 7 字段卡片、CBT 四问扩展

## 仓库检查

```bash
npm run prompt:check
cd ios && xcodebuild -scheme Yeyu -destination 'platform=iOS Simulator,name=iPhone 17' build
```
