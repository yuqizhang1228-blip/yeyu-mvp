// src/types/index.ts
// ==========================================
// 全局 TypeScript 类型定义
// ==========================================

// 用户类型
export interface User {
  id: string;
  createdAt: string;
}

// 消息类型
export interface Message {
  id: string;
  role: 'user' | 'ai';
  content: string;
  timestamp: string;
}

// 念想卡片类型
export interface MemoryCard {
  id: string;
  title: string;
  date: string;
  originalThought: string;
  newPerspective: string;
  emotion: string;
  microAction: string;
  reflection: string;
}

// CBT 流程状态
export type CBTStep = 1 | 2 | 3 | 4 | 5;

export interface CBTSession {
  id: string;
  step: CBTStep;
  situation?: string;
  automaticThought?: string;
  emotion?: string;
  emotionIntensity?: number;
  newPerspective?: string;
  microAction?: string;
  messages: Message[];
  createdAt: string;
  updatedAt: string;
}

// API 响应类型（定义在 src/services/ai.ts，避免重复）

// 主题类型
export type ThemeMode = 'light' | 'dark';
