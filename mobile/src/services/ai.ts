// src/services/ai.ts
// DeepSeek API 封装（兼容 OpenAI 格式）

import { DEEPSEEK_API_KEY } from '@env';
import type { Message } from '../types';
import { CBT_SYSTEM_PROMPT, CRISIS_KEYWORDS } from '../constants/cbt';

const DEEPSEEK_API_URL = 'https://api.deepseek.com/v1/chat/completions';
const MAX_HISTORY = 20; // 保留最近20条，避免 token 膨胀

export interface SendMessageParams {
  messages: Message[];
  sessionId: string;
  step: number;
  context?: Record<string, string>;
}

export interface AIResponse {
  content: string;
}

export const aiService = {
  checkCrisisKeywords(text: string): boolean {
    return CRISIS_KEYWORDS.some(kw => text.includes(kw));
  },

  async sendMessage(params: SendMessageParams): Promise<AIResponse> {
    const { messages, step, context = {} } = params;

    // 注入当前步骤状态到 system prompt
    const systemPrompt = CBT_SYSTEM_PROMPT
      .replace('{currentStep}', `Step ${step}`)
      .replace('{extractedContext}', JSON.stringify(context));

    // 转换消息格式：'ai' -> 'assistant'（DeepSeek 要求）
    const apiMessages = messages.slice(-MAX_HISTORY).map(msg => ({
      role: msg.role === 'ai' ? 'assistant' : msg.role,
      content: msg.content,
    }));

    const response = await fetch(DEEPSEEK_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${DEEPSEEK_API_KEY ?? ''}`,
      },
      body: JSON.stringify({
        model: 'deepseek-chat',
        messages: [
          { role: 'system', content: systemPrompt },
          ...apiMessages,
        ],
        temperature: 0.8,
        max_tokens: 600,
        stream: false, // 移动端暂用非流式，体验上用 loading 态代替
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`DeepSeek API 错误: ${response.status} ${error}`);
    }

    const data = await response.json();
    const content: string = data.choices?.[0]?.message?.content ?? '抱歉，我遇到了一点问题，请稍后再试。';

    return { content };
  },
};

export default aiService;
