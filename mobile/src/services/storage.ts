// src/services/storage.ts
// 本地存储服务（MMKV 高性能存储）

import { MMKV } from 'react-native-mmkv';
import type { MemoryCard, CBTSession } from '../types';

// MMKV 实例（高性能存储）
const storage = new MMKV();

// Storage Keys
const KEYS = {
  SESSIONS: 'yeyu_sessions',
  MEMORY_CARDS: 'yeyu_memory_cards',
  USER_PREFERENCES: 'yeyu_user_preferences',
};

export const storageService = {
  // ===== MMKV 基础方法 =====
  
  setString(key: string, value: string): void {
    storage.set(key, value);
  },

  getString(key: string): string | undefined {
    return storage.getString(key);
  },

  setObject<T>(key: string, value: T): void {
    storage.set(key, JSON.stringify(value));
  },

  getObject<T>(key: string): T | undefined {
    const json = storage.getString(key);
    if (!json) return undefined;
    try {
      return JSON.parse(json) as T;
    } catch {
      return undefined;
    }
  },

  delete(key: string): void {
    storage.delete(key);
  },

  // ===== 业务方法 =====
  
  /**
   * 保存 CBT 会话
   */
  saveSession(session: CBTSession): void {
    const sessions = this.getSessions();
    const index = sessions.findIndex(s => s.id === session.id);
    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.push(session);
    }
    this.setObject(KEYS.SESSIONS, sessions);
  },

  /**
   * 获取所有会话
   */
  getSessions(): CBTSession[] {
    return this.getObject<CBTSession[]>(KEYS.SESSIONS) || [];
  },

  /**
   * 保存念想卡片
   */
  saveMemoryCard(card: MemoryCard): void {
    const cards = this.getMemoryCards();
    cards.unshift(card); // 新卡片放前面
    this.setObject(KEYS.MEMORY_CARDS, cards);
  },

  /**
   * 获取所有念想卡片
   */
  getMemoryCards(): MemoryCard[] {
    return this.getObject<MemoryCard[]>(KEYS.MEMORY_CARDS) || [];
  },

  /**
   * 清除所有数据
   */
  clearAll(): void {
    storage.clearAll();
  },
};

export default storageService;
