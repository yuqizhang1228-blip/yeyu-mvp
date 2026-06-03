// src/store/useAppStore.ts
// 全局状态管理（Zustand）

import { create } from 'zustand';

interface AppStore {
  isDarkMode: boolean;
  fontScale: number;
  toggleDarkMode: () => void;
  setFontScale: (scale: number) => void;
}

export const useAppStore = create<AppStore>((set) => ({
  isDarkMode: true, // 夜屿默认深色
  fontScale: 1,
  toggleDarkMode: () => set((state) => ({ isDarkMode: !state.isDarkMode })),
  setFontScale: (scale) => set({ fontScale: scale }),
}));

export default useAppStore;
