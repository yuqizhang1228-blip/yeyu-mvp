# POST /api/chat — 接口契约文档

> **端点**: `POST /api/chat`
> **实现**: `api/chat.js`（Vercel Serverless Function）
> **本地开发**: `server.js` 在 `localhost:3000` 代理同一端点
> **后端**: DeepSeek-V3 (`deepseek-chat`)，通过 `DEEPSEEK_API_KEY` 鉴权

---

## 请求（Request）

### Headers

| 字段 | 值 |
|------|-----|
| `Content-Type` | `application/json` |

### Body（JSON）

```typescript
{
  model?:       string;   // 默认 "deepseek-chat"
  max_tokens?:  number;   // 默认 500
  temperature?: number;   // 默认 0.7
  top_p?:       number;   // 默认 0.9
  messages:     Message[];  // 必填，至少 1 条
}

type Message = {
  role:    "system" | "user" | "assistant";
  content: string;
}
```

### 字段说明

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `model` | string | `"deepseek-chat"` | DeepSeek 模型名称 |
| `max_tokens` | number | `500` | 最大输出 token 数 |
| `temperature` | number | `0.7` | 生成温度（0～2，越高越随机） |
| `top_p` | number | `0.9` | 核采样阈值（0～1） |
| `messages` | Message[] | — | **必填**。消息数组，按对话顺序排列 |

### messages 结构（主对话）

主对话（`callAI()`）发送的 messages 格式：

```json
[
  {
    "role": "system",
    "content": "<system_production.md 中的完整提示词>"
  },
  {
    "role": "system",
    "content": "【当前时间】现在是深夜（翻来覆去，脑子里停不下来）\n<可选：用户画像摘要>"
  },
  {
    "role": "user",
    "content": "今天开会被当众否了 心里堵得慌"
  },
  {
    "role": "assistant",
    "content": "当众被否……"
  }
]
```

规则：
- 第一条固定为主对话 system prompt（`system_production.md`）
- 第二条为动态 context（时段 + 可选用户画像），每次请求不同
- 之后为 `conversationHistory`（user/assistant 交替）

### messages 结构（Chip 生成）

```json
[
  {
    "role": "system",
    "content": "<chip_generation.md 中的完整提示词，含 period 和 timeHint 替换后的值>"
  },
  {
    "role": "system",
    "content": "本地记忆摘要：..."
  },
  {
    "role": "user",
    "content": "生成5个深夜可能遇到的情绪场景。..."
  }
]
```

注：第二条 system message（记忆摘要）仅在存在本地记忆时附加。

### messages 结构（历史标题生成）

```json
[
  {
    "role": "system",
    "content": "<history_title.md 中的完整提示词>"
  },
  {
    "role": "user",
    "content": "今天开会被当众否了 心里堵得慌"
  },
  {
    "role": "assistant",
    "content": "当众被否……"
  },
  {
    "role": "user",
    "content": "请为这段对话生成标题。"
  }
]
```

---

## 响应（Response）

### 成功（200 OK）

直接透传 DeepSeek API 的原始响应：

```typescript
{
  id:      string;
  object:  "chat.completion";
  created: number;
  model:   string;
  choices: [
    {
      index:         number;
      message: {
        role:    "assistant";
        content: string;
      };
      finish_reason: "stop" | "length" | "content_filter";
    }
  ];
  usage: {
    prompt_tokens:     number;
    completion_tokens: number;
    total_tokens:      number;
  };
}
```

前端取值路径：`data.choices[0].message.content`

### 错误响应

| HTTP 状态码 | 说明 | body |
|------------|------|------|
| `405` | 非 POST 请求 | `{"error": "Method not allowed"}` |
| `401` | DeepSeek API Key 无效 | `{"error": "DeepSeek API Key 无效或已失效，请到 platform.deepseek.com 检查并更新 .env"}` |
| `500` | 服务器内部错误（Key 未设置 / 网络故障） | `{"error": "..."}` |
| 其他 DeepSeek 错误码 | 透传 DeepSeek 错误信息 | `{"error": "..."}` |

---

## 调用示例（curl）

```bash
curl -X POST https://yeyu-mvp.vercel.app/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "max_tokens": 500,
    "temperature": 0.7,
    "top_p": 0.9,
    "messages": [
      {
        "role": "system",
        "content": "你是夜屿小岛的守夜人..."
      },
      {
        "role": "system",
        "content": "【当前时间】现在是深夜（翻来覆去，脑子里停不下来）"
      },
      {
        "role": "user",
        "content": "今天很累"
      }
    ]
  }'
```

---

## 环境变量

| 变量名 | 说明 | 设置位置 |
|--------|------|----------|
| `DEEPSEEK_API_KEY` | DeepSeek API 密钥 | Vercel 环境变量 / 本地 `.env.local` |

---

## iOS 集成说明

iOS 客户端可直接复用本端点：

```
https://yeyu-mvp.vercel.app/api/chat
```

- 无需额外鉴权（Key 存于服务端）
- iOS 端自行构造 `messages` 数组（参考上述三种结构）
- `system_production.md` / `chip_generation.md` / `history_title.md` 中的提示词内容可在 iOS 构建时嵌入（Build Phase 拷贝）或运行时从 `prompts/` 目录读取
