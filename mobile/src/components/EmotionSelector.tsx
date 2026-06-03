// src/components/EmotionSelector.tsx
// ==========================================
// 情绪选择器组件（占位）
// ==========================================

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { colors, spacing, borderRadius, typography } from '../constants/theme';

const EMOTIONS = [
  { key: 'anxious', label: '焦虑', color: colors.emotion.anxious },
  { key: 'sad', label: '悲伤', color: colors.emotion.sad },
  { key: 'angry', label: '愤怒', color: colors.emotion.angry },
  { key: 'tired', label: '疲惫', color: colors.emotion.tired },
  { key: 'calm', label: '平静', color: colors.emotion.calm },
];

interface EmotionSelectorProps {
  selected?: string;
  onSelect: (emotion: string) => void;
}

export const EmotionSelector: React.FC<EmotionSelectorProps> = ({
  selected,
  onSelect,
}) => {
  return (
    <View style={styles.container}>
      <Text style={styles.label}>选择你现在的感受：</Text>
      <View style={styles.emotionsRow}>
        {EMOTIONS.map((emotion) => (
          <TouchableOpacity
            key={emotion.key}
            style={[
              styles.emotionButton,
              selected === emotion.key && {
                borderColor: emotion.color,
                backgroundColor: `${emotion.color}20`,
              },
            ]}
            onPress={() => onSelect(emotion.key)}
          >
            <View
              style={[
                styles.colorDot,
                { backgroundColor: emotion.color },
              ]}
            />
            <Text style={styles.emotionLabel}>{emotion.label}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: spacing.md,
  },
  label: {
    fontSize: typography.size.md,
    color: colors.text.secondary,
    marginBottom: spacing.md,
  },
  emotionsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  emotionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    borderRadius: borderRadius.full,
    borderWidth: 1,
    borderColor: colors.border.DEFAULT,
    backgroundColor: colors.background.surface,
  },
  colorDot: {
    width: 8,
    height: 8,
    borderRadius: borderRadius.full,
    marginRight: spacing.xs,
  },
  emotionLabel: {
    fontSize: typography.size.sm,
    color: colors.text.primary,
  },
});

export default EmotionSelector;
