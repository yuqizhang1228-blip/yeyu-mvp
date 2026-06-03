// src/constants/theme.ts
// ==========================================
// 夜屿 (YeYu) Design Tokens — v2 (与 Figma 同步)
// 禁止在组件内写死颜色或像素值，必须引用此文件
// ==========================================

export const colors = {
  // 背景层级
  background: {
    base: '#0B111D',     // 页面底色（深海蓝黑）
    surface: '#161B22',  // 卡片/消息气泡背景
    elevated: '#1A1F26', // 浮层/次级背景
    input: '#292F39',    // 输入框背景
    overlay: 'rgba(0,0,0,0.80)', // 抽屉遮罩
  },

  // 品牌色 — 琥珀橙（与 Figma button-primary-bg 同步）
  primary: {
    DEFAULT: '#FFB86C',
    light: '#FFCF99',
    dark: '#E6993A',
    muted: 'rgba(255,184,108,0.15)',
  },

  // 次要强调色
  accent: {
    cyan: '#06B6D4',
    blue: '#3B82F6',
    purple: '#8B5CF6',
    orange: '#F97316',
    rose: '#F43F5E',
  },

  // 文字颜色
  text: {
    title: '#F2F5FF',     // 标题（最亮）
    primary: '#E0E7FF',   // 正文
    secondary: '#A9B2CC', // 次要
    tertiary: '#707A94',  // 辅助/占位
    inverse: '#0B111D',   // 反色（用于亮色背景按钮上的文字）
  },

  // 情绪指示器
  emotion: {
    calm: '#06B6D4',
    happy: '#22C55E',
    anxious: '#EAB308',
    sad: '#3B82F6',
    angry: '#EF4444',
    tired: '#71717A',
    stressed: '#F97316',
    fearful: '#8B5CF6',
    frustrated: '#F97316',
  },

  // 状态色
  state: {
    success: '#22C55E',
    warning: '#EAB308',
    error: '#EF4444',
    info: '#3B82F6',
  },

  // 边框
  border: {
    DEFAULT: 'rgba(255,255,255,0.06)',
    muted: '#161B22',
    focus: 'rgba(255,184,108,0.5)',
    active: 'rgba(255,255,255,0.12)',
  },
};

// 间距系统（基于 4px 网格）
export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  xxxxl: 48,
};

// 圆角系统
export const borderRadius = {
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  xxl: 20,
  full: 9999,
};

// 字体系统
export const typography = {
  size: {
    xs: 10,
    sm: 12,
    md: 14,
    lg: 16,
    xl: 18,
    xxl: 22,
    xxxl: 24,
  },
  weight: {
    regular: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
  },
  lineHeight: {
    tight: 1.2,
    normal: 1.4,
    relaxed: 1.6,
  },
};

// 阴影
export const shadow = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.3,
    shadowRadius: 2,
    elevation: 2,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 4,
    elevation: 4,
  },
  glow: {
    shadowColor: '#FFB86C',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.25,
    shadowRadius: 16,
    elevation: 6,
  },
};

// 动画时长
export const duration = {
  fast: 150,
  normal: 200,
  slow: 300,
};

export const theme = {
  colors,
  spacing,
  borderRadius,
  typography,
  shadow,
  duration,
};

export default theme;
