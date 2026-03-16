// provider: 'deepseek' | 'minimax'，默认 deepseek，与 body 同传
// MINIMAX 官方文档：https://platform.minimax.io/docs/api-reference/text-post（M2.5 文本生成）
const DEEPSEEK_URL = 'https://api.deepseek.com/v1/chat/completions';
const MINIMAX_URL = 'https://api.minimaxi.com/v1/text/chatcompletion_v2';
const MINIMAX_MODEL = 'MiniMax-M2.5'; // 官方 model id，同文档

function buildDeepSeekBody(body) {
  return {
    model: body.model || 'deepseek-chat',
    max_tokens: body.max_tokens ?? 500,
    temperature: body.temperature ?? 0.7,
    top_p: body.top_p ?? 0.9,
    messages: body.messages || []
  };
}

function buildMinimaxBody(body) {
  // MINIMAX 不允许连续多条同 role 消息，需合并连续的 system 消息
  const rawMsgs = (body.messages || []).map(m => ({
    role: m.role,
    content: typeof m.content === 'string' ? m.content : (m.content || '')
  }));
  const merged = [];
  for (const m of rawMsgs) {
    const prev = merged[merged.length - 1];
    if (prev && prev.role === m.role) {
      prev.content += '\n' + m.content;
    } else {
      merged.push({ ...m });
    }
  }
  return {
    model: MINIMAX_MODEL,
    max_completion_tokens: body.max_tokens ?? 500,
    temperature: body.temperature ?? 0.7,
    top_p: body.top_p ?? 0.95,
    messages: merged
  };
}

function parseResponse(data, provider) {
  if (provider === 'minimax' && data.base_resp?.status_code !== 0 && data.base_resp?.status_code !== undefined) {
    return { error: data.base_resp.status_msg || 'MINIMAX API 错误', status: data.base_resp.status_code };
  }
  const content = data.choices?.[0]?.message?.content;
  if (content !== undefined) return { ...data, choices: [{ message: { role: 'assistant', content } }] };
  return data;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const provider = (req.body?.provider || 'deepseek').toLowerCase();

  if (provider === 'deepseek') {
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
        return res.status(response.status).json({ error: response.status === 401 ? 'DeepSeek API Key 无效或已失效，请到 platform.deepseek.com 检查并更新 .env' : msg });
      }
      return res.status(200).json(data);
    } catch (err) {
      console.error('DeepSeek API error:', err);
      return res.status(500).json({ error: 'API request failed' });
    }
  }

  if (provider === 'minimax') {
    const apiKey = (process.env.MINIMAX_API_KEY || '').trim();
    if (!apiKey) {
      return res.status(500).json({ error: 'MINIMAX_API_KEY 未设置' });
    }
    try {
      const response = await fetch(MINIMAX_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify(buildMinimaxBody(req.body))
      });
      const data = await response.json();
      if (response.status === 401 || [1004, 2049].includes(data?.base_resp?.status_code)) {
        return res.status(500).json({ error: 'MINIMAX API Key 无效或已失效，请到 platform.minimax.io 检查并更新 .env' });
      }
      const normalized = parseResponse(data, 'minimax');
      if (normalized.error) {
        return res.status(500).json({ error: normalized.error });
      }
      return res.status(200).json(normalized);
    } catch (err) {
      console.error('MINIMAX API error:', err);
      return res.status(500).json({ error: 'API request failed' });
    }
  }

  return res.status(400).json({ error: '不支持的 provider，仅支持 deepseek / minimax' });
}
