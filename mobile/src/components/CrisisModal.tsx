// src/components/CrisisModal.tsx
// ==========================================
// 危机干预弹窗组件
// ==========================================

import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Modal,
  StyleSheet,
  Linking,
} from 'react-native';
import { colors, spacing, borderRadius, typography } from '../constants/theme';

interface CrisisModalProps {
  visible: boolean;
  onClose: () => void;
}

const CRISIS_HOTLINES = [
  { name: '全国24小时心理危机干预热线', number: '400-161-9995' },
  { name: '北京心理危机研究与干预中心', number: '010-82951332' },
  { name: '生命热线', number: '400-821-1215' },
];

export const CrisisModal: React.FC<CrisisModalProps> = ({ visible, onClose }) => {
  const handleCall = (number: string) => {
    Linking.openURL(`tel:${number}`);
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <View style={styles.container}>
          <Text style={styles.icon}>🆘</Text>
          
          <Text style={styles.title}>
            我们注意到你可能正处于困境中
          </Text>
          
          <Text style={styles.description}>
            你表达的内容让我们很担心。请记住，你并不孤单，有人愿意帮助你。
          </Text>

          <View style={styles.hotlinesSection}>
            <Text style={styles.hotlinesTitle}>危机援助热线</Text>
            {CRISIS_HOTLINES.map((hotline) => (
              <TouchableOpacity
                key={hotline.number}
                style={styles.hotlineButton}
                onPress={() => handleCall(hotline.number)}
              >
                <Text style={styles.hotlineName}>{hotline.name}</Text>
                <Text style={styles.hotlineNumber}>{hotline.number}</Text>
              </TouchableOpacity>
            ))}
          </View>

          <TouchableOpacity style={styles.closeButton} onPress={onClose}>
            <Text style={styles.closeButtonText}>继续对话</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: colors.background.overlay,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.lg,
  },
  container: {
    backgroundColor: colors.background.elevated,
    borderRadius: borderRadius.xl,
    padding: spacing.xl,
    width: '100%',
    maxWidth: 340,
    alignItems: 'center',
  },
  icon: {
    fontSize: 48,
    marginBottom: spacing.md,
  },
  title: {
    fontSize: typography.size.lg,
    fontWeight: typography.weight.bold as any,
    color: colors.text.primary,
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  description: {
    fontSize: typography.size.md,
    color: colors.text.secondary,
    textAlign: 'center',
    marginBottom: spacing.lg,
    lineHeight: typography.lineHeight.normal * typography.size.md,
  },
  hotlinesSection: {
    width: '100%',
    marginBottom: spacing.lg,
  },
  hotlinesTitle: {
    fontSize: typography.size.sm,
    fontWeight: typography.weight.semibold as any,
    color: colors.text.tertiary,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  hotlineButton: {
    backgroundColor: colors.state.error,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    borderRadius: borderRadius.md,
    marginBottom: spacing.sm,
    alignItems: 'center',
  },
  hotlineName: {
    fontSize: typography.size.sm,
    color: colors.text.inverse,
    fontWeight: typography.weight.medium as any,
  },
  hotlineNumber: {
    fontSize: typography.size.lg,
    color: colors.text.inverse,
    fontWeight: typography.weight.bold as any,
    marginTop: spacing.xs,
  },
  closeButton: {
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.xl,
  },
  closeButtonText: {
    fontSize: typography.size.md,
    color: colors.text.secondary,
  },
});

export default CrisisModal;
