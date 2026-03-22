import 'dotenv/config';
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import chatHandler from './api/chat.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// 复用 api/chat.js 的代理逻辑（含 DEEPSEEK_API_KEY 引用）
app.post('/api/chat', (req, res) => chatHandler(req, res));

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
