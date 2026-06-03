// src/screens/HomeScreen.tsx
// 首页 — 与 Figma homepage 同步

import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  TextInput,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../navigation/AppNavigator';
import { colors, spacing, borderRadius, typography } from '../constants/theme';
import { SideDrawer } from '../components/SideDrawer';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const SUGGESTIONS = [
  '与同事有矛盾，不知道如何处理。',
  '感觉最近压力很大，情绪不好。',
  '感觉孤立无援，失去沟通渠道。',
];

const HomeScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();
  const [input, setInput] = useState('');
  const [drawerOpen, setDrawerOpen] = useState(false);

  const startChat = (text?: string) => {
    if (!text?.trim()) return;
    const sessionId = Date.now().toString();
    navigation.navigate('Chat', { sessionId, initialMessage: text.trim() });
    setInput('');
  };

  const handleDrawerNavigate = (
    screen: 'Settings' | 'Mood' | 'Support' | 'Chat',
    params?: { sessionId: string },
  ) => {
    setDrawerOpen(false);
    if (screen === 'Settings') {
      navigation.navigate('Settings');
    } else if (screen === 'Chat' && params) {
      navigation.navigate('Chat', { sessionId: params.sessionId });
    }
  };

  return (
    <View style={styles.container}>
      {/* Header — hamburger menu */}
      <View style={[styles.header, { paddingTop: insets.top + spacing.sm }]}>
        <TouchableOpacity
          style={styles.menuBtn}
          onPress={() => setDrawerOpen(true)}
          hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
        >
          <View style={styles.menuLine} />
          <View style={[styles.menuLine, styles.menuLineShort]} />
          <View style={styles.menuLine} />
        </TouchableOpacity>
      </View>

      {/* Main content — centered orb + greeting */}
      <View style={styles.mainContent}>
        {/* Island orb placeholder — replace with actual image when assets are ready */}
        <View style={styles.orb} />
        <Text style={styles.greeting}>晚上好</Text>
        <Text style={styles.subtitle}>现在让我们的思绪像河流一样流淌</Text>
      </View>

      {/* Footer — suggestion cards + input bar */}
      <View style={styles.footer}>
        {/* Horizontally scrollable suggestion cards */}
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.cardsRow}
        >
          {SUGGESTIONS.map((text, i) => (
            <TouchableOpacity
              key={i}
              style={styles.suggestionCard}
              onPress={() => startChat(text)}
              activeOpacity={0.75}
            >
              <Text style={styles.suggestionText}>{text}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Pill input bar */}
        <View style={styles.inputArea}>
          <View style={styles.inputPill}>
            <TextInput
              style={styles.inputField}
              value={input}
              onChangeText={setInput}
              placeholder="随便聊聊..."
              placeholderTextColor={colors.text.secondary}
              returnKeyType="send"
              onSubmitEditing={() => startChat(input)}
            />
            <TouchableOpacity
              style={[styles.sendBtn, !input.trim() && styles.sendBtnDisabled]}
              onPress={() => startChat(input)}
              disabled={!input.trim()}
            >
              <Text style={styles.sendArrow}>▶</Text>
            </TouchableOpacity>
          </View>
          <Text style={[styles.disclaimer, { paddingBottom: insets.bottom + spacing.sm }]}>
            本功能无法代替医学等安全合规声明
          </Text>
        </View>
      </View>

      {/* Side drawer */}
      <SideDrawer
        visible={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        onNavigate={handleDrawerNavigate}
      />
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
    paddingHorizontal: spacing.xl,
    paddingBottom: spacing.sm,
  },
  menuBtn: {
    width: 24,
    height: 18,
    justifyContent: 'space-between',
  },
  menuLine: {
    height: 1.5,
    width: 20,
    backgroundColor: colors.text.primary,
    borderRadius: 1,
  },
  menuLineShort: {
    width: 14,
  },

  // Main content
  mainContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.xl,
    gap: spacing.lg,
  },
  orb: {
    width: 140,
    height: 140,
    borderRadius: 70,
    backgroundColor: colors.background.elevated,
    borderWidth: 1,
    borderColor: colors.border.active,
    marginBottom: spacing.sm,
    shadowColor: colors.primary.DEFAULT,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.2,
    shadowRadius: 24,
    elevation: 6,
  },
  greeting: {
    fontSize: typography.size.xl,
    fontWeight: typography.weight.regular as '400',
    color: colors.text.primary,
    textAlign: 'center',
    lineHeight: 22,
  },
  subtitle: {
    fontSize: typography.size.lg,
    fontWeight: typography.weight.regular as '400',
    color: colors.text.primary,
    textAlign: 'center',
  },

  // Footer
  footer: {
    gap: spacing.sm,
  },
  cardsRow: {
    paddingHorizontal: spacing.xl,
    gap: spacing.md,
  },
  suggestionCard: {
    width: 161,
    minHeight: 68,
    backgroundColor: colors.background.elevated,
    borderRadius: borderRadius.xl,
    padding: spacing.lg,
    justifyContent: 'center',
  },
  suggestionText: {
    fontSize: typography.size.sm,
    color: colors.text.secondary,
    lineHeight: typography.size.sm * typography.lineHeight.relaxed,
  },
  inputArea: {
    paddingHorizontal: spacing.xl,
    gap: spacing.sm,
  },
  inputPill: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.background.input,
    borderRadius: borderRadius.full,
    height: 49,
    paddingLeft: spacing.lg,
    paddingRight: 5,
    borderWidth: 1,
    borderColor: colors.border.muted,
  },
  inputField: {
    flex: 1,
    fontSize: typography.size.sm,
    color: colors.text.secondary,
    paddingVertical: 0,
  },
  sendBtn: {
    width: 39,
    height: 39,
    borderRadius: 18,
    backgroundColor: colors.primary.DEFAULT,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sendBtnDisabled: {
    opacity: 0.4,
  },
  sendArrow: {
    fontSize: 13,
    color: colors.text.inverse,
    fontWeight: typography.weight.bold as '700',
  },
  disclaimer: {
    fontSize: typography.size.xs,
    color: colors.text.tertiary,
    textAlign: 'center',
  },
});

export default HomeScreen;
