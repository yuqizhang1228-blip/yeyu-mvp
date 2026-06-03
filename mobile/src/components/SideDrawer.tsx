// src/components/SideDrawer.tsx
// ==========================================
// 左侧滑出抽屉菜单（与 Figma left menu 同步）
// ==========================================

import React, { useEffect, useRef, useState } from 'react';
import {
  Animated,
  Modal,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { storageService } from '../services/storage';
import type { CBTSession } from '../types';
import { colors, spacing, typography, borderRadius } from '../constants/theme';

const DRAWER_WIDTH = 304;

interface SideDrawerProps {
  visible: boolean;
  onClose: () => void;
  onNavigate: (screen: 'Settings' | 'Mood' | 'Support' | 'Chat', params?: { sessionId: string }) => void;
}

interface NavItemProps {
  icon: string;
  label: string;
  onPress: () => void;
}

const NavItem: React.FC<NavItemProps> = ({ icon, label, onPress }) => (
  <TouchableOpacity style={styles.navItem} onPress={onPress} activeOpacity={0.7}>
    <View style={styles.navItemLeft}>
      <Text style={styles.navIcon}>{icon}</Text>
      <Text style={styles.navLabel}>{label}</Text>
    </View>
    <Text style={styles.chevron}>›</Text>
  </TouchableOpacity>
);

export const SideDrawer: React.FC<SideDrawerProps> = ({ visible, onClose, onNavigate }) => {
  const insets = useSafeAreaInsets();
  const slideAnim = useRef(new Animated.Value(-DRAWER_WIDTH)).current;
  const [shouldRender, setShouldRender] = useState(false);
  const [sessions, setSessions] = useState<CBTSession[]>([]);

  useEffect(() => {
    if (visible) {
      setSessions(storageService.getSessions().slice(0, 12));
      setShouldRender(true);
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 250,
        useNativeDriver: true,
      }).start();
    } else {
      Animated.timing(slideAnim, {
        toValue: -DRAWER_WIDTH,
        duration: 200,
        useNativeDriver: true,
      }).start(() => setShouldRender(false));
    }
  }, [visible, slideAnim]);

  if (!shouldRender) return null;

  const getSessionTitle = (session: CBTSession): string => {
    const firstUserMsg = session.messages.find(m => m.role === 'user');
    return firstUserMsg?.content.slice(0, 22) ?? '对话记录';
  };

  return (
    <Modal
      visible={shouldRender}
      transparent
      animationType="none"
      onRequestClose={onClose}
      statusBarTranslucent
    >
      {/* Dark overlay (full screen) */}
      <View style={StyleSheet.absoluteFill} pointerEvents="none">
        <View style={styles.overlay} />
      </View>

      {/* Drawer panel */}
      <Animated.View
        style={[
          styles.drawer,
          { transform: [{ translateX: slideAnim }], paddingTop: insets.top },
        ]}
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerTextBlock}>
            <Text style={styles.appName}>夜屿</Text>
            <Text style={styles.appSlogan}>安放情绪的岛屿</Text>
          </View>
          <View style={styles.headerIcons}>
            <TouchableOpacity style={styles.headerIconBtn} onPress={onClose}>
              <Text style={styles.headerIconText}>✕</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* 成为会员 banner */}
        <TouchableOpacity style={styles.memberBanner} activeOpacity={0.8}>
          <Text style={styles.memberText}>成为会员</Text>
        </TouchableOpacity>

        {/* Nav items */}
        <View style={styles.navList}>
          <NavItem icon="♡" label="心情" onPress={() => onNavigate('Mood')} />
          <NavItem icon="◇" label="支持" onPress={() => onNavigate('Support')} />
          <NavItem icon="◎" label="设置" onPress={() => onNavigate('Settings')} />
        </View>

        {/* 对话历史 */}
        <View style={styles.historySection}>
          <Text style={styles.historyTitle}>对话</Text>
          <ScrollView showsVerticalScrollIndicator={false}>
            {sessions.length === 0 ? (
              <Text style={styles.historyEmpty}>还没有对话记录</Text>
            ) : (
              sessions.map(session => (
                <TouchableOpacity
                  key={session.id}
                  style={styles.historyItem}
                  onPress={() => onNavigate('Chat', { sessionId: session.id })}
                  activeOpacity={0.7}
                >
                  <Text style={styles.historyItemText} numberOfLines={1}>
                    {getSessionTitle(session)}
                  </Text>
                </TouchableOpacity>
              ))
            )}
          </ScrollView>
        </View>
      </Animated.View>

      {/* Right-side tap area to close */}
      <TouchableOpacity
        style={styles.closeArea}
        onPress={onClose}
        activeOpacity={1}
      />
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: colors.background.overlay,
  },
  drawer: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    width: DRAWER_WIDTH,
    backgroundColor: colors.background.base,
    paddingHorizontal: spacing.xl,
    paddingBottom: spacing.xxl,
  },
  closeArea: {
    position: 'absolute',
    left: DRAWER_WIDTH,
    right: 0,
    top: 0,
    bottom: 0,
  },

  // Header
  header: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingTop: spacing.lg,
    paddingBottom: spacing.xl,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.DEFAULT,
    marginBottom: spacing.xl,
  },
  headerTextBlock: {
    gap: spacing.xs,
  },
  appName: {
    fontSize: typography.size.xxxl,
    fontWeight: '400' as const,
    color: colors.text.title,
    lineHeight: typography.size.xxxl,
  },
  appSlogan: {
    fontSize: typography.size.sm,
    color: colors.text.secondary,
  },
  headerIcons: {
    flexDirection: 'row',
    gap: spacing.md,
    alignItems: 'center',
    paddingBottom: spacing.xs,
  },
  headerIconBtn: {
    padding: spacing.xs,
  },
  headerIconText: {
    fontSize: typography.size.md,
    color: colors.text.secondary,
  },

  // 会员 banner
  memberBanner: {
    height: 56,
    backgroundColor: colors.background.input,
    borderRadius: borderRadius.sm,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.xxl,
  },
  memberText: {
    fontSize: typography.size.lg,
    fontWeight: '500' as const,
    color: colors.primary.DEFAULT,
  },

  // Nav
  navList: {
    gap: spacing.xl,
    marginBottom: spacing.xxl,
  },
  navItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  navItemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  navIcon: {
    fontSize: typography.size.lg,
    color: colors.text.primary,
    width: 20,
    textAlign: 'center',
  },
  navLabel: {
    fontSize: typography.size.lg,
    color: colors.text.title,
  },
  chevron: {
    fontSize: typography.size.xl,
    color: colors.text.tertiary,
  },

  // History
  historySection: {
    flex: 1,
  },
  historyTitle: {
    fontSize: typography.size.md,
    color: colors.text.tertiary,
    marginBottom: spacing.xl,
  },
  historyItem: {
    paddingVertical: spacing.sm,
  },
  historyItemText: {
    fontSize: typography.size.lg,
    color: colors.text.title,
  },
  historyEmpty: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },
});

export default SideDrawer;
