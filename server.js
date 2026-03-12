import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// API 代理到 DeepSeek
app.post('/api/chat', async (req, res) => {
  const apiKey = process.env.DEEPSEEK_API_KEY;
  if (!apiKey) {
    console.error('[ERROR] DEEPSEEK_API_KEY 未设置');
    return res.status(500).json({ error: 'DEEPSEEK_API_KEY 未设置' });
  }

  console.log('[API] 收到请求, model:', req.body?.model);

  try {
    const response = await fetch('https://api.deepseek.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('[DeepSeek ERROR]', response.status, JSON.stringify(data));
    } else {
      console.log('[API] 响应成功, tokens:', data.usage?.total_tokens);
    }

    res.status(response.status).json(data);
  } catch (err) {
    console.error('[FETCH ERROR]', err.message);
    res.status(500).json({ error: err.message });
  }
});

// 静态托管整个目录，默认入口 index.html
app.use(express.static(__dirname, { index: 'index.html' }));

// 端口绑定失败时给出清晰提示
app.listen(PORT, () => {
  console.log(`✅ 夜屿本地预览已启动: http://localhost:${PORT}`);
  console.log(`   DEEPSEEK_API_KEY: ${process.env.DEEPSEEK_API_KEY ? '已设置 ✓' : '未设置 ✗'}`);
}).on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`[ERROR] 端口 ${PORT} 已被占用，请先执行: lsof -ti :${PORT} | xargs kill -9`);
  } else {
    console.error('[ERROR]', err.message);
  }
  process.exit(1);
});
