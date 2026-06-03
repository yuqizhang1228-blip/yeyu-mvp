# 夜屿 (Night Isle) 项目深度上下文

> 本文件是 AI 助手的「长期记忆」，记录项目历史、关键决策、当前状态和待解决问题。  
> 每次重要决策或状态变更后请更新本文件。

---

## 一、项目简介

**夜屿**（Night Isle，英文 MVP 期曾用名 Mindflow）是 YUQI 的个人独立项目。

**核心命题**：当你深夜翻来覆去停不下来，打开夜屿，它陪你把堵在胸口的那件事理清楚，最后带走一张写着「今晚能做什么」的小卡片。

**不是**：心理咨询、诊断、治疗、鸡汤安慰  
**是**：深夜树洞、结构化情绪梳理、可执行的微行动

**目标用户**：25-35 岁职场人，情绪事件频发（工作压力、人际关系、自我怀疑）

**最终形态**：iOS App Store（**SwiftUI + SwiftData** + DeepSeek via Vercel API）  
**当前阶段**：H5 MVP 验证 + **`ios/`** SwiftUI 客户端（单一 monorepo，见 `MONOREPO.md`）  
**仓库策略（2026-06）**：只维护 **`yeyu-mvp`**；`mobile/` RN 试验已归档（2026-06-02 改 SwiftUI）。

---

## 二、产品演进历史

### Phase 1：Mindflow 概念期（2026年2月前）
- 以 **Mindflow** 命名，完成完整 PRD、市场调研报告、Figma 设计系统
- 理论基础：CBT（认知行为疗法）情绪拆解 5 步法
- iOS 目标架构：React Native + TypeScript + Zustand + DeepSeek API

### Phase 2：夜屿品牌确立（2026年2月）
- 品牌从 Mindflow 切换至**夜屿 (Night Isle)**
- 视觉语言确立：Digital Hearth 隐喻、AI 光球(Orb)、暗色调（`#121620`）、橙色光晕（`#FF9F68`）
- Design Tokens 三层体系：Primitive → Semantic → Component
- 目标上线时间设定：2026年2月16-20日（iOS App Store）

### Phase 3：H5 MVP 快速构建（2026年2月-3月）
- 技术决策：用**纯 HTML 单文件**快速验证，不用 React Native
- 核心文件：`index.html`（全部前端代码内联）+ `api/chat.js`（Vercel 代理）
- 首次上线：[yeyu-mvp.vercel.app](https://yeyu-mvp.vercel.app/)
- 提示词从 v1 → v2.1 → v2.2 持续迭代（详见 `PROMPT_HISTORY.md`）

### Phase 4：全链路验证 + 提示词精调（2026年3月）
- 目标：跑通完整用户体验链路，提示词精细化调整
- 已完成：v2.2 → v2.4 提示词（结构公式、温度感、出卡轮次与安全边界）
- H5 持续根据真实用户反馈迭代

### Phase 5：iOS 原生客户端 · 端改造一期（当前，2026年6月）
- **路线 B 冻结**：SwiftUI + SwiftData（`ios/`），放弃以 RN 为主工程
- **P0 已实装**：昵称首访、对话、三选一、出卡确认、卡片条、SwiftData 会话、抽屉续聊、行动卡片列表、危机检测等（验收见 `ios/P0_ACCEPTANCE.md`）
- **Prompt 抽离**：`prompts/*.md` + `npm run prompt:check` / `prompt:sync-ios` + iOS Bundle
- **视觉策略**：Token 对齐 `YeyuDesignTokens` / H5 CSS；Figma 高保真 v1 不做
- **RN 试验稿**：`mobile/` 归档，仅查阅

---

## 三、核心产品机制

### 行动卡片（核心输出）
```json
{
  "thought": "「用户脑子里最刺的那句自我否定」",
  "reframe": "一句基于本次对话的具体新视角（不能是鸡汤）",
  "actions": [
    "什么时候 + 对谁/对什么 + 做什么（具体到10分钟内可完成）",
    "另一件和本次情绪直接相关的具体行为"
  ]
}
```

### 4 阶段对话流
1. **接住**（前 2-3 轮）：一句话点出感受，问具体问题
2. **探针**（中间几轮）：挖出「脑子里最刺的那句话」+ 情绪标注（0-10分）
3. **松动**（接近收尾）：CBT 认知重构——证据检验 + 朋友视角
4. **收束与卡片**：软上限 8 轮兜底，输出 `<card>` JSON

### 时间感知机制
`getTimeContext()` 根据当前小时返回时段：
- 清晨（5-8）/ 上午（8-12）/ 午后（12-17）/ 傍晚（17-19）/ 夜晚（19-22）/ 深夜（22-5）

AI 根据时段调整：开场白氛围、微行动时间合理性、语气轻重

### 安全边界（不可更改）
检测「不想活了」「想消失」「不知道活着有什么意思」→ 立即停止流程，给出全国 24 小时心理危机热线：**400-161-9995**

---

## 四、技术实现细节

### index.html 关键位置索引
| 内容 | 大约行号 |
|------|---------|
| CSS 变量 / 设计 Token | 7-25 行 |
| 页面 HTML 结构 | ~100-1380 行 |
| SYSTEM_PROMPT 定义 | ~1392 行 |
| `callAI()` 函数 | ~1554 行 |
| `getTimeContext()` | 在 callAI 前 |
| `<card>` 标签解析逻辑 | callAI 响应处理内 |
| `generateChips()` | callAI 之后 |
| localStorage 操作 | 分散在各事件处理器中 |

### localStorage Key 说明
| Key | 内容 |
|-----|------|
| `yeyu_username` | 用户昵称 |
| `yeyu_uid` | 用户匿名 ID |
| `yeyu_cards` | 所有行动卡片（JSON 数组） |
| `yeyu_history` | 所有对话历史（JSON 数组，含 AI 自动生成的标题） |

### API 参数（当前）
```
model: deepseek-chat
temperature: 0.7
top_p: 0.9
max_tokens: 500
```

### 本地开发
```bash
export DEEPSEEK_API_KEY="your-key"
npm run dev   # → localhost:3000
```

---

## 五、H5 vs iOS（当前对齐策略）

| 维度 | H5（`index.html`） | iOS（`ios/`）v1 |
|------|-------------------|-----------------|
| 主 Prompt | 内联 `SYSTEM_PROMPT` v2.4 | Bundle 读 `system_production.md`（须与 H5 同步） |
| Chip / 历史标题 | 内联 system 文案 | `chip_system.md` / `history_title_system.md` |
| API | `/api/chat` | 同生产代理 URL |
| 对话风格 | 4 阶段自然流动 | 同 Prompt，行为应对齐 H5 |
| 时间感知 | ✅ `getTimeContext()` | ✅ `TimeContext.swift` |
| 卡片字段 | 3 字段 + `<card>` JSON | 同解析 `CardParser` |
| 本地存储 | localStorage | SwiftData（`YeyuStore_v2`） |
| 认知重构深度 | 2 问（规划扩展） | 同 H5，未单独加深 |
| 流式 | ❌ | ❌（v1.1） |

**原则**：v1 以 H5 验证过的 Prompt 与交互为准；iOS 不另起一套「5 步严格流程」除非产品书面变更。

---

## 六、当前待解决问题

### iOS · 产品验收后
- [ ] 按 `ios/P0_ACCEPTANCE.md` 统一验收并收 Linear YUQ-41～50
- [ ] TestFlight + 合规文案（YUQ-49，P0 外）

### H5 + 共用 Prompt
- [ ] 持续根据真实对话迭代 v2.4+；改 Prompt 走 `PROMPT_HISTORY.md` + `prompt:check`
- [ ] 确认 Vercel `DEEPSEEK_API_KEY` 有效
- [ ] 各时段开场白与 Chip 场景抽检

### v1.1+（勿与 P0 混做）
- [ ] SSE 流式（`api/chat.js`）
- [ ] 非危机结束免责声明
- [ ] CBT 四问、卡片 7+ 字段
- [ ] iOS Chip 本地记忆摘要（对齐 H5 `getProfileSummaryForChips`）

---

## 七、关键设计决策记录

| 时间 | 决策 | 原因 |
|------|------|------|
| 2026-02 | 放弃 Mindflow 品牌，改用夜屿 | 中文名更有情感温度，贴近目标用户 |
| 2026-02 | 用纯 HTML 单文件做 H5 MVP | 最快速验证，零框架零数据库，无需后端 |
| 2026-03 | 提示词针对 DeepSeek 定向优化 | DeepSeek 有鸡汤倾向、话多、过度配合三大问题 |
| 2026-03 | 开场白改为「结构公式」而非「示例模板」 | 避免每次开场白雷同，让模型有创作空间 |
| 2026-03 | 行动卡片用 `<card>` 标签包裹 JSON | 方便前端正则解析，与对话文本清晰分离 |
| 2026-06-02 | iOS 选定 SwiftUI 原生，`mobile/` RN 归档 | 路线 B；单一 monorepo `yeyu-mvp` |
| 2026-06 | iOS v1 视觉策略：Token 对齐、不做 Figma 像素级 | 功能骨架优先，设计轨并行 |
| 2026-06 | Prompt 抽离至 `prompts/` + iOS Bundle | `prompt:check` / `prompt:sync-ios` 防漂移 |

---

## 八、Notion 文档索引

| 文档 | URL |
|------|-----|
| 夜屿文档中心（总入口） | https://www.notion.so/9574dabb82c74475bdc9a1e2cfab31c3 |
| 项目中心（里程碑/任务） | https://www.notion.so/89d1ab25338d462b9220cd705da6e45d |
| 提示词方案 v2.1（DeepSeek优化版） | https://www.notion.so/32120f214f7281e08f43cff2c28087a5 |
| iOS v2.0 提示词参考 | README 中有链接 |

---

*最后更新：2026-06-02（iOS P0 + Agent 文档对齐）*
