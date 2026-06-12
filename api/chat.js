// 通义千问 Chat Completions（OpenAI 兼容，Vercel / 本地 server 共用）
const DASHSCOPE_BASE_URL = (
  process.env.DASHSCOPE_BASE_URL ||
  'https://ws-ejtv8grbnjqdnirb.cn-beijing.maas.aliyuncs.com/compatible-mode/v1'
).replace(/\/$/, '');
const CHAT_URL = `${DASHSCOPE_BASE_URL}/chat/completions`;
const DEFAULT_MODEL = process.env.DASHSCOPE_MODEL || 'qwen3-max';

function buildChatBody(body) {
  const payload = {
    model: body.model || DEFAULT_MODEL,
    max_tokens: body.max_tokens ?? 500,
    temperature: body.temperature ?? 0.7,
    top_p: body.top_p ?? 0.9,
    messages: body.messages || []
  };
  if (body.stream === true) {
    payload.stream = true;
  }
  return payload;
}

async function pipeUpstreamStream(upstream, res) {
  res.setHeader('Content-Type', 'text/event-stream; charset=utf-8');
  res.setHeader('Cache-Control', 'no-cache, no-transform');
  res.setHeader('Connection', 'keep-alive');
  if (typeof res.flushHeaders === 'function') {
    res.flushHeaders();
  }

  const reader = upstream.body.getReader();
  const decoder = new TextDecoder();
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      res.write(decoder.decode(value, { stream: true }));
    }
  } finally {
    res.end();
  }
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const apiKey = (process.env.DASHSCOPE_API_KEY || '').trim();
  if (!apiKey) {
    return res.status(500).json({ error: 'DASHSCOPE_API_KEY 未设置' });
  }

  const wantStream = req.body?.stream === true;

  try {
    const response = await fetch(CHAT_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify(buildChatBody(req.body))
    });

    if (!response.ok) {
      let data = {};
      try {
        data = await response.json();
      } catch {
        // ignore parse error
      }
      const msg = data?.error?.message || data?.error || `通义千问返回 ${response.status}`;
      return res.status(response.status).json({
        error: response.status === 401
          ? 'DASHSCOPE_API_KEY 无效或已失效，请到阿里云百炼控制台检查并更新环境变量'
          : msg
      });
    }

    if (wantStream) {
      if (!response.body) {
        return res.status(502).json({ error: '上游未返回流式 body' });
      }
      await pipeUpstreamStream(response, res);
      return;
    }

    const data = await response.json();
    return res.status(200).json(data);
  } catch (err) {
    console.error('DashScope API error:', err);
    if (!res.headersSent) {
      return res.status(500).json({ error: 'API request failed' });
    }
    res.end();
  }
}
