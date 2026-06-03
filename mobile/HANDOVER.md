# 夜屿 (Yeyu) — 交接白板

> 公司与家里「共享白板」。换设备或换地点时，优先阅读本文件以恢复上下文。与 `.cursorrules`、Notion Wiki 共同构成记忆同步体系。

---

## 当前状态

- **基建**：已完成。React Native 0.73 + TypeScript、Zustand、MMKV、React Navigation、DeepSeek API 封装已就绪。
- **Design Tokens**：`src/constants/theme.ts` 已就绪，所有 UI 组件均引用该文件，无硬编码色值/尺寸。
- **本地规范**：根目录 `.cursorrules` 已固化（D2C 设计铁律、技术栈约束、排版规范）。
- **Notion**：【夜屿 (Yeyu) 核心架构与开发 Wiki】已创建，记录技术全景与跨端 SOP。

---

## 待办事项

1. **确认 .env 配置**  
   根目录 `.env` 需包含 `DEEPSEEK_API_KEY`（或项目所需其它 key）。确认后可在 Chat 等页正常调用 DeepSeek。

2. **运行 iOS 模拟器**  
   - 终端 1：`npm run start`（或 `npx react-native start`）启动 Metro。  
   - 终端 2：`npm run ios`（或 `npx react-native run-ios`）构建并启动模拟器。  
   - 若 Hermes 构建报错，检查 `ios/.xcode.env.local` 中 `NODE_BINARY` 是否指向本机 node（如 `/opt/homebrew/bin/node`）。

3. **编写 DeepSeek CBT System Prompt**  
   在 `src/constants/cbt.ts` 中完善 `CBT_SYSTEM_PROMPT`，使 AI 回复符合夜屿的 CBT 情绪疏导与安全岛定位。

---

## 快速命令

```bash
# 安装依赖
npm install && cd ios && pod install && cd ..

# 启动 Metro
npm run start

# 启动 iOS 模拟器（另开终端，Metro 已运行时可用 --no-packager）
npm run ios
```

---

*最后更新：基建与 Wiki 初始化完成。*
