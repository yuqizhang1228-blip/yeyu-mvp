// src/screens/ChatScreen.tsx
// 对话页 — 与 Figma 对话页同步

import React, { useState, useRef, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp, NativeStackScreenProps } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../navigation/AppNavigator';
import { colors, spacing, borderRadius, typography } from '../constants/theme';
import { ChatBubble } from '../components/ChatBubble';
import { CrisisModal } from '../components/CrisisModal';
import { SideDrawer } from '../components/SideDrawer';
import { useChat } from '../hooks/useChat';
import { CRISIS_KEYWORDS } from '../constants/cbt';

type Props = NativeStackScreenProps<RootStackParamList, 'Chat'>;
type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const ChatScreen: React.FC<Props> = ({ route }) => {
  const { sessionId, initialMessage } = route.params;
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();
  const [input, setInput] = useState('');
  const [showCrisis, setShowCrisis] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const flatListRef = useRef<FlatList>(null);
  const initialMessageSent = useRef(false);

  const { messages, isLoading, sendMessage } = useChat(sessionId);

  // Send initial message once on mount
  useEffect(() => {
    if (initialMessage && !initialMessageSent.current) {
      initialMessageSent.current = true;
      if (CRISIS_KEYWORDS.some(kw => initialMessage.includes(kw))) {
        setShowCrisis(true);
      }
      sendMessage(initialMessage);
    }
  }, [initialMessage, sendMessage]);

  // Auto-scroll to bottom on new messages
  useEffect(() => {
    if (messages.length > 0) {
      setTimeout(() => flatListRef.current?.scrollToEnd({ animated: true }), 100);
    }
  }, [messages]);

  const handleSend = useCallback(async () => {
    if (!input.trim() || isLoading) return;
    const text = input.trim();
    setInput('');
    if (CRISIS_KEYWORDS.some(kw => text.includes(kw))) {
      setShowCrisis(true);
    }
    await sendMessage(text);
  }, [input, isLoading, sendMessage]);

  const handleDrawerNavigate = (
    screen: 'Settings' | 'Mood' | 'Support' | 'Chat',
    params?: { sessionId: string },
  ) => {
    setDrawerOpen(false);
    if (screen === 'Settings') {
      navigation.navigate('Settings');
    } else if (screen === 'Chat' && params && params.sessionId !== sessionId) {
      navigation.replace('Chat', { sessionId: params.sessionId });
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      keyboardVerticalOffset={0}
    >
      {/* Header — hamburger menu only */}
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

      {/* Message list */}
      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={item => item.id}
        renderItem={({ item }) => (
          <ChatBubble role={item.role} content={item.content} />
        )}
        contentContainerStyle={styles.messageList}
        showsVerticalScrollIndicator={false}
      />

      {/* Typing indicator */}
      {isLoading && (
        <View style={styles.typingRow}>
          <ActivityIndicator size="small" color={colors.primary.DEFAULT} />
          <Text style={styles.typingText}>夜屿正在思考...</Text>
        </View>
      )}

      {/* Input bar */}
      <View style={styles.inputArea}>
        <View style={styles.inputPill}>
          <TextInput
            style={styles.inputField}
            value={input}
            onChangeText={setInput}
            placeholder="随便聊聊..."
            placeholderTextColor={colors.text.secondary}
            multiline
            maxLength={500}
          />
          <TouchableOpacity
            style={[styles.sendBtn, (!input.trim() || isLoading) && styles.sendBtnDisabled]}
            onPress={handleSend}
            disabled={!input.trim() || isLoading}
          >
            <Text style={styles.sendArrow}>▶</Text>
          </TouchableOpacity>
        </View>
        <Text style={[styles.disclaimer, { paddingBottom: insets.bottom + spacing.xs }]}>
          本功能无法代替医学等安全合规声明
        </Text>
      </View>

      {/* Crisis modal */}
      <CrisisModal visible={showCrisis} onClose={() => setShowCrisis(false)} />

      {/* Side drawer */}
      <SideDrawer
        visible={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        onNavigate={handleDrawerNavigate}
      />
    </KeyboardAvoidingView>
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

  // Messages
  messageList: {
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.lg,
    flexGrow: 1,
  },
  typingRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    paddingHorizontal: spacing.xl,
    paddingBottom: spacing.sm,
  },
  typingText: {
    fontSize: typography.size.sm,
    color: colors.text.tertiary,
  },

  // Input bar
  inputArea: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.sm,
    gap: spacing.xs,
    borderTopWidth: 1,
    borderTopColor: colors.border.DEFAULT,
    backgroundColor: colors.background.base,
  },
  inputPill: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    backgroundColor: colors.background.input,
    borderRadius: borderRadius.full,
    minHeight: 49,
    paddingLeft: spacing.lg,
    paddingRight: 5,
    paddingVertical: 5,
    borderWidth: 1,
    borderColor: colors.border.muted,
  },
  inputField: {
    flex: 1,
    fontSize: typography.size.sm,
    color: colors.text.secondary,
    maxHeight: 100,
    paddingVertical: spacing.sm,
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

export default ChatScreen;
