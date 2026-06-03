# 夜屿 Chat API 契约

生产地址：`https://yeyu-mvp.vercel.app/api/chat`  
本地 H5：`http://localhost:3000/api/chat`（`npm run dev`）

## 请求

- **Method**：`POST`
- **Content-Type**：`application/json`

```json
{
  "model": "deepseek-chat",
  "max_tokens": 500,
  "temperature": 0.7,
  "top_p": 0.9,
  "stream": false,
  "messages": [
    { "role": "system", "content": "..." },
    { "role": "user", "content": "..." },
    { "role": "assistant", "content": "..." }
  ]
}
```

## 约定

| 场景 | system 条数 | 说明 |
|------|-------------|------|
| 主对话 | 1～2 | `system_production.md` + 可选时段 `【当前时间】...` |
| Chip 生成 | 1 | `chip_system.md`，`max_tokens` 建议 320 |
| 历史标题 | 1 | `history_title_system.md`，`max_tokens` 建议 60 |

## 流式（v1.1，iOS 优先）

请求体设 `"stream": true` 时，响应为 **DeepSeek 兼容 SSE**（`text/event-stream`），逐条 `data: {...}`，结束为 `data: [DONE]`。

- 实现：`api/chat.js` 透传上游流
- iOS：`ChatAPIClient.sendStream`；失败时自动回退非流式 `send`
- **注意**：仅在你**自行部署**的 Vercel/本地环境生效；未部署前 iOS 会自动走回退

## 响应（非流式）

OpenAI 兼容格式：`choices[0].message.content` 为助手文本。

出卡时 content 内含 `<card>{"thought":"...","reframe":"...","actions":["...","..."]}</card>`。

## 客户端

- **H5**：`index.html` → `getChatPayload()` / `callAI()`
- **iOS**：`ios/Yeyu/Services/ChatAPIClient.swift`
- **评测**：`evals/yeyu_eval.js` 读取 `prompts/system_production.md`

## 同步检查

```bash
npm run prompt:check      # H5 主 prompt 与 index.html 一致
npm run prompt:sync-ios   # 复制三份 md 到 ios/Yeyu/Resources/Prompts/
```

校验 `index.html` 内联 `SYSTEM_PROMPT` 与 `prompts/system_production.md` 一致。
