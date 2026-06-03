// src/components/MicroActionCard.tsx
// ==========================================
// 微行动卡片组件（占位）
// ==========================================

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, spacing, borderRadius, typography, shadow } from '../constants/theme';

interface MicroActionCardProps {
  action: string;
  timeframe?: string;
}

export const MicroActionCard: React.FC<MicroActionCardProps> = ({
  action,
  timeframe = '明天',
}) => {
  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Text style={styles.icon}>🎯</Text>
      </View>
      <View style={styles.content}>
        <Text style={styles.label}>这周试试</Text>
        <Text style={styles.action}>{action}</Text>
        {timeframe && (
          <Text style={styles.timeframe}>{timeframe}</Text>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: colors.background.surface,
    borderRadius: borderRadius.lg,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.primary.muted,
    ...shadow.sm,
  },
  iconContainer: {
    marginRight: spacing.md,
  },
  icon: {
    fontSize: typography.size.xxl,
  },
  content: {
    flex: 1,
  },
  label: {
    fontSize: typography.size.sm,
    color: colors.primary.light,
    fontWeight: typography.weight.medium as any,
    marginBottom: spacing.xs,
  },
  action: {
    fontSize: typography.size.md,
    color: colors.text.primary,
    lineHeight: typography.lineHeight.normal * typography.size.md,
    marginBottom: spacing.sm,
  },
  timeframe: {
    fontSize: typography.size.sm,
    color: colors.text.secondary,
  },
});

export default MicroActionCard;
