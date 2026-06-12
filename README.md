# 夜屿 (Yeyu) - H5 情绪陪伴工具

> 一个基于通义千问 AI 的情绪梳理工具，帮你在 10-15 分钟内理清情绪，获得可执行的微行动。

[在线体验](https://yeyu-mvp.vercel.app/) | [项目文档](https://www.notion.so/夜屿-H5测试版-提示词方案)

---

## 是什么

夜屿是一个轻量级的情绪陪伴工具。当你：
- 深夜翻来覆去脑子里停不下来
- 被工作/人际关系卡住
- 有情绪但不知道从何说起

打开夜屿，它陪你把堵在胸口的那件事理清楚，最后带走一张写着"今晚能做什么"的小卡片。

**不是**：心理咨询、诊断、治疗、鸡汤安慰  
**是**：深夜树洞、结构化梳理、可执行的行动

---

## 仓库结构（Monorepo）

**只需维护本仓库**即可覆盖 H5 + iOS + API + Prompt 评测。详见 **[MONOREPO.md](./MONOREPO.md)**。  
使用 AI 编码助手时请先读 **[AGENTS.md](./AGENTS.md)**（或 **[CLAUDE.md](./CLAUDE.md)**）。

| 目录 | 说明 |
|------|------|
| `index.html` | H5 MVP（Vercel 线上） |
| `ios/` | SwiftUI 原生 iOS App |
| `mobile/` | RN 试验稿（已归档） |
| `api/` | 通义千问代理（H5 / App 共用） |

## 技术栈

- **H5**：纯 HTML/CSS/JS，单页面应用
- **iOS**：SwiftUI + SwiftData（`ios/`，iOS 17+）
- **后端**：Vercel Serverless Function (`api/chat.js`) 代理通义千问 API
- **AI 模型**：qwen3-max
- **部署**：H5 → Vercel；App → Xcode / TestFlight

---

## 本地开发

```bash
# 克隆项目
git clone https://github.com/yuqizhang1228-blip/yeyu-mvp.git
cd yeyu-mvp

# 安装依赖
npm install

# 设置环境变量并启动
export DASHSCOPE_API_KEY="your-api-key"
npm run dev

# 打开 http://localhost:3000
```

---

## 核心机制

**提示词工程 (Prompt Engineering)**

系统提示词针对 DeepSeek 的特性做了定向优化：
- 禁止清单封堵高频鸡汤废话
- 对话节奏跟着情绪走，而非固定字数
- 4 阶段自然流动：接住 → 探针 → 松动 → 收束
- 8 轮软上限兜底，确保一定生成行动卡片

**行动卡片格式**

```json
{
  "thought": "用户那句最刺的自我否定",
  "reframe": "基于对话的具体新视角",
  "actions": ["今晚能做的具体小事", "另一件相关行动"]
}
```

---

## 项目结构

```
yeyu-mvp/
├── index.html          # H5 主页面（含 SYSTEM_PROMPT）
├── ios/                # SwiftUI iOS App
├── mobile/             # RN 归档（见 ARCHIVED.md）
├── api/chat.js         # 通义千问 API 代理
├── prompts/            # 提示词版本
├── evals/              # Braintrust 评测
├── server.js           # 本地 H5 开发服务器
├── MONOREPO.md         # 单一入口说明（建议先读）
└── README.md
```

---

## 相关链接

- [设计文档 - Notion](https://www.notion.so/夜屿-H5测试版-提示词方案)
- [iOS 版本提示词参考](https://www.notion.so/iOS-版本提示词)

---

## 免责声明

夜屿是一个情绪自助工具，不能替代专业心理咨询或医疗诊断。如果你的困扰持续或加重，建议寻求专业帮助。

危机热线：全国 24 小时心理危机干预热线 400-161-9995
