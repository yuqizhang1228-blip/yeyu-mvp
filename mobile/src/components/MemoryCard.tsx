// src/components/MemoryCard.tsx
// ==========================================
// 念想卡片组件（占位）
// ==========================================

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import type { MemoryCard as MemoryCardType } from '../types';
import { colors, spacing, borderRadius, typography, shadow } from '../constants/theme';

interface MemoryCardProps {
  card: MemoryCardType;
  onPress?: (card: MemoryCardType) => void;
}

export const MemoryCard: React.FC<MemoryCardProps> = ({ card, onPress }) => {
  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress?.(card)}
      activeOpacity={0.8}
    >
      <View style={styles.header}>
        <Text style={styles.title}>{card.title}</Text>
        <Text style={styles.date}>{card.date}</Text>
      </View>
      
      <View style={styles.emotionBadge}>
        <Text style={styles.emotionText}>{card.emotion}</Text>
      </View>
      
      <View style={styles.thoughts}>
        <View style={styles.thoughtRow}>
          <Text style={styles.thoughtLabel}>💭 原来：</Text>
          <Text style={styles.thoughtText} numberOfLines={1}>
            {card.originalThought}
          </Text>
        </View>
        <View style={styles.thoughtRow}>
          <Text style={styles.thoughtLabel}>🌱 现在：</Text>
          <Text style={styles.thoughtText} numberOfLines={1}>
            {card.newPerspective}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.background.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadow.sm,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
  },
  title: {
    fontSize: typography.size.lg,
    fontWeight: typography.weight.semibold as any,
    color: colors.text.primary,
    flex: 1,
  },
  date: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },
  emotionBadge: {
    backgroundColor: colors.primary.muted,
    paddingVertical: spacing.xs,
    paddingHorizontal: spacing.sm,
    borderRadius: borderRadius.sm,
    alignSelf: 'flex-start',
    marginBottom: spacing.md,
  },
  emotionText: {
    fontSize: typography.size.sm,
    color: colors.primary.light,
    fontWeight: typography.weight.medium as any,
  },
  thoughts: {
    gap: spacing.xs,
  },
  thoughtRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  thoughtLabel: {
    fontSize: typography.size.sm,
    color: colors.text.secondary,
  },
  thoughtText: {
    fontSize: typography.size.sm,
    color: colors.text.primary,
    flex: 1,
  },
});

export default MemoryCard;
