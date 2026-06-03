// src/screens/SettingsScreen.tsx
// 设置页 — 与 Figma setting 页同步

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../navigation/AppNavigator';
import { colors, spacing, typography } from '../constants/theme';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface SettingRowProps {
  icon: string;
  label: string;
  onPress?: () => void;
}

const SettingRow: React.FC<SettingRowProps> = ({ icon, label, onPress }) => (
  <TouchableOpacity
    style={styles.row}
    onPress={onPress}
    disabled={!onPress}
    activeOpacity={0.7}
  >
    <View style={styles.rowLeft}>
      <Text style={styles.rowIcon}>{icon}</Text>
      <Text style={styles.rowLabel}>{label}</Text>
    </View>
    <Text style={styles.rowChevron}>›</Text>
  </TouchableOpacity>
);

const SettingsScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={[styles.header, { paddingTop: insets.top }]}>
        <TouchableOpacity
          style={styles.backBtn}
          onPress={() => navigation.goBack()}
          hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
        >
          <Text style={styles.backIcon}>‹</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>设置</Text>
        <View style={styles.backBtn} />
      </View>

      <ScrollView
        style={styles.scroll}
        contentContainerStyle={[styles.content, { paddingBottom: insets.bottom + spacing.xxxxl }]}
        showsVerticalScrollIndicator={false}
      >
        {/* General section — no section title */}
        <View style={styles.section}>
          <SettingRow icon="○" label="一起共创" onPress={() => {}} />
          <SettingRow icon="□" label="关于产品" onPress={() => {}} />
          <SettingRow icon="✉" label="联系我们" onPress={() => {}} />
        </View>

        {/* 系统 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>系统</Text>
          <SettingRow icon="⏳" label="防沉迷提醒" onPress={() => {}} />
          <SettingRow icon="⊕" label="界面语言" onPress={() => {}} />
        </View>

        {/* 重要 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>重要</Text>
          <SettingRow icon="☁" label="iCloud" onPress={() => {}} />
          <SettingRow
            icon="🗑"
            label="删除本地数据"
            onPress={() => {
              // TODO: 二次确认后清除
            }}
          />
        </View>

        {/* Footer links */}
        <View style={styles.footer}>
          <TouchableOpacity>
            <Text style={styles.footerLink}>隐私政策</Text>
          </TouchableOpacity>
          <TouchableOpacity>
            <Text style={styles.footerLink}>服务条款</Text>
          </TouchableOpacity>
          <Text style={styles.footerVersion}>夜屿 1.0</Text>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background.base,
  },

  // Header
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.xl,
    paddingBottom: spacing.md,
    backgroundColor: colors.background.base,
  },
  backBtn: {
    width: 40,
    alignItems: 'flex-start',
    justifyContent: 'center',
  },
  backIcon: {
    fontSize: 28,
    color: colors.text.primary,
    lineHeight: 32,
  },
  headerTitle: {
    fontSize: typography.size.xl,
    fontWeight: typography.weight.regular as '400',
    color: colors.text.title,
    lineHeight: 22,
  },

  scroll: {
    flex: 1,
  },
  content: {
    paddingHorizontal: spacing.xl,
  },

  // Sections
  section: {
    marginTop: spacing.xxxl,
    gap: spacing.xxl,
  },
  sectionTitle: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },

  // Row
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  rowLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  rowIcon: {
    fontSize: typography.size.lg,
    color: colors.text.primary,
    width: 20,
    textAlign: 'center',
  },
  rowLabel: {
    fontSize: typography.size.lg,
    color: colors.text.primary,
  },
  rowChevron: {
    fontSize: typography.size.xl,
    color: colors.text.tertiary,
    lineHeight: typography.size.xl * 1.2,
  },

  // Footer
  footer: {
    marginTop: spacing.xxxxl * 2,
    gap: spacing.xl,
  },
  footerLink: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },
  footerVersion: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },

});

export default SettingsScreen;
