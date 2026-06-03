// src/hooks/useChat.ts
// 聊天逻辑 Hook - 整合 AI 服务 + CBT 流程

import { useState, useCallback, useRef } from 'react';
import type { Message } from '../types';
import { aiService } from '../services/ai';
import { storageService } from '../services/storage';
import { useCBTFlow } from './useCBTFlow';

// 解析念想卡片
function parseMemoryCard(text: string, sessionId: string) {
  if (!text.includes('---念想卡片---')) return null;
  const titleMatch = text.match(/【(.+?)】/);
  const thoughtMatch = text.match(/💭 原来的想法：(.+)/);
  const perspectiveMatch = text.match(/🌱 新的视角：(.+)/);
  const actionMatch = text.match(/🎯 这周试试：(.+)/);
  const reflectionMatch = text.match(/🤔 留给你：(.+)/);
  if (!titleMatch || !thoughtMatch || !perspectiveMatch || !actionMatch) return null;
  return {
    id: sessionId + '_card',
    title: titleMatch[1],
    date: new Date().toLocaleDateString('zh-CN'),
    originalThought: thoughtMatch[1].trim(),
    newPerspective: perspectiveMatch[1].trim(),
    microAction: actionMatch[1].trim(),
    reflection: reflectionMatch?.[1].trim() ?? '',
    emotion: '',
  };
}

export const useChat = (sessionId: string) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const cbt = useCBTFlow();
  const sessionRef = useRef(sessionId);

  const sendMessage = useCallback(async (content: string) => {
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content,
      timestamp: new Date().toISOString(),
    };

    setMessages(prev => [...prev, userMessage]);
    setIsLoading(true);

    try {
      const updatedMessages = [...messages, userMessage];

      const response = await aiService.sendMessage({
        messages: updatedMessages,
        sessionId: sessionRef.current,
        step: cbt.step,
        context: {
          situation: cbt.situation ?? '',
          automaticThought: cbt.automaticThought ?? '',
          emotion: cbt.emotion ?? '',
          newPerspective: cbt.newPerspective ?? '',
          microAction: cbt.microAction ?? '',
        },
      });

      const aiMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'ai',
        content: response.content,
        timestamp: new Date().toISOString(),
      };

      setMessages(prev => [...prev, aiMessage]);

      // 根据 AI 回复内容推进 CBT 步骤
      const reply = response.content;
      if (cbt.step === 1 && (reply.includes('最刺痛') || reply.includes('脑子里'))) {
        cbt.setSituation(content); // 把用户这条消息作为情境
      } else if (cbt.step === 2 && (reply.includes('感受') || reply.includes('情绪') || reply.includes('几分'))) {
        cbt.setAutomaticThought(content);
      } else if (cbt.step === 3 && (reply.includes('其他可能') || reply.includes('还可能') || reply.includes('证据'))) {
        cbt.setEmotion(content, 5);
      } else if (cbt.step === 4 && (reply.includes('微行动') || reply.includes('明天可以') || reply.includes('这周试试'))) {
        cbt.setNewPerspective(content);
      } else if (cbt.step === 5 && reply.includes('---念想卡片---')) {
        cbt.setMicroAction(content);
        // 解析并保存念想卡片
        const card = parseMemoryCard(reply, sessionRef.current);
        if (card) storageService.saveMemoryCard(card);
      }

    } catch (error) {
      console.error('发送消息失败:', error);
      setMessages(prev => [...prev, {
        id: (Date.now() + 1).toString(),
        role: 'ai',
        content: '遇到了一点问题，请稍后再试。',
        timestamp: new Date().toISOString(),
      }]);
    } finally {
      setIsLoading(false);
    }
  }, [messages, cbt]);

  return {
    messages,
    isLoading,
    currentStep: cbt.step,
    sendMessage,
  };
};

export default useChat;
