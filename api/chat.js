// DeepSeek Chat Completions（Vercel / 本地 server 共用）
const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

function isAllowedOrigin(req) {
  const origin = req.headers['origin'] || '';
  const referer = req.headers['referer'] || '';
  if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) return true;
  if (referer.startsWith('http://localhost:') || referer.startsWith('http://127.0.0.1:')) return true;
  if (!origin && !referer) return process.env.NODE_ENV !== 'production';
  const allowedRaw = process.env.ALLOWED_ORIGIN || '';
  const allowed = allowedRaw ? allowedRaw.split(',').map(s => s.trim()).filter(Boolean) : [];
  if (origin) {
    if (allowed.some(a => origin === a)) return true;
    try { if (new URL(origin).hostname.endsWith('.vercel.app')) return true; } catch {}
  }
  if (referer) {
    if (allowed.some(a => referer.startsWith(a))) return true;
    try { if (new URL(referer).hostname.endsWith('.vercel.app')) return true; } catch {}
  }
  return false;
}

function validateBody(body) {
  if (!body || typeof body !== 'object') return '请求体必须是 JSON 对象';
  const { messages, max_tokens } = body;
  if (!Array.isArray(messages) || messages.length === 0) return 'messages 无效';
  if (messages.length > 40) return 'messages 条数超出限制';
  for (const m of messages) {
    if (!m || !['system', 'user', 'assistant'].includes(m.role)) return '无效 role';
    if (typeof m.content !== 'string' || m.content.length > 8000) return '消息内容超出限制';
  }
  if (max_tokens !== undefined && (typeof max_tokens !== 'number' || max_tokens < 1 || max_tokens > 2000)) {
    return 'max_tokens 超出范围';
  }
  return null;
}

function buildDeepSeekBody(body) {
  return {
    model: body.model || 'deepseek-chat',
    max_tokens: body.max_tokens ?? 500,
    temperature: body.temperature ?? 0.7,
    top_p: body.top_p ?? 0.9,
    messages: body.messages || []
  };
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  if (!isAllowedOrigin(req)) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  const bodyError = validateBody(req.body);
  if (bodyError) {
    return res.status(400).json({ error: bodyError });
  }

  const apiKey = (process.env.DEEPSEEK_API_KEY || '').trim();
  if (!apiKey) {
    return res.status(500).json({ error: 'DEEPSEEK_API_KEY 未设置' });
  }

  try {
    const response = await fetch(DEEPSEEK_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify(buildDeepSeekBody(req.body))
    });
    const data = await response.json();
    if (!response.ok) {
      const msg = data?.error?.message || data?.error || `DeepSeek 返回 ${response.status}`;
      return res.status(response.status).json({
        error: response.status === 401
          ? 'DeepSeek API Key 无效或已失效，请到 platform.deepseek.com 检查并更新 .env'
          : msg
      });
    }
    return res.status(200).json(data);
  } catch (err) {
    console.error('DeepSeek API error:', err);
    return res.status(500).json({ error: 'API request failed' });
  }
}
