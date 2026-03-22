// DeepSeek Chat Completions（Vercel / 本地 server 共用）
const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';

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
