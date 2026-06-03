// src/components/ChatBubble.tsx
// 聊天气泡 — 与 Figma 对话页消息设计同步
//   用户：右对齐，深色气泡，无头像
//   AI ：左对齐，头像 + "夜屿" 标签，全宽气泡

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, spacing, borderRadius, typography } from '../constants/theme';

interface ChatBubbleProps {
  role: 'user' | 'ai';
  content: string;
}

export const ChatBubble: React.FC<ChatBubbleProps> = ({ role, content }) => {
  if (role === 'ai') {
    return (
      <View style={styles.aiWrapper}>
        {/* Header: avatar + name */}
        <View style={styles.aiHeader}>
          <View style={styles.aiAvatar} />
          <Text style={styles.aiName}>夜屿</Text>
        </View>
        {/* Message bubble */}
        <View style={styles.aiBubble}>
          <Text style={styles.aiText}>{content}</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.userWrapper}>
      <View style={styles.userBubble}>
        <Text style={styles.userText}>{content}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  // AI message
  aiWrapper: {
    alignSelf: 'flex-start',
    width: '100%',
    marginBottom: spacing.xxl,
    gap: spacing.md,
  },
  aiHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  aiAvatar: {
    width: 23,
    height: 23,
    borderRadius: 12,
    backgroundColor: colors.background.elevated,
    borderWidth: 1,
    borderColor: colors.border.active,
  },
  aiName: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },
  aiBubble: {
    backgroundColor: colors.background.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    width: '100%',
  },
  aiText: {
    fontSize: typography.size.md,
    color: colors.text.primary,
    lineHeight: typography.size.md * typography.lineHeight.relaxed,
  },

  // User message
  userWrapper: {
    alignSelf: 'flex-end',
    maxWidth: '60%',
    marginBottom: spacing.xxl,
  },
  userBubble: {
    backgroundColor: colors.background.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.md,
  },
  userText: {
    fontSize: typography.size.md,
    color: colors.text.primary,
    lineHeight: typography.size.md * typography.lineHeight.normal,
  },
});

export default ChatBubble;
