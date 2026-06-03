// src/screens/HistoryScreen.tsx
// 念想卡片历史页

import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import type { RootStackParamList } from '../navigation/AppNavigator';
import { colors, spacing, borderRadius, typography } from '../constants/theme';
import { storageService } from '../services/storage';
import type { MemoryCard } from '../types';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const HistoryScreen: React.FC = () => {
  const navigation = useNavigation<NavigationProp>();
  const insets = useSafeAreaInsets();
  const [cards, setCards] = useState<MemoryCard[]>([]);

  useFocusEffect(
    useCallback(() => {
      setCards(storageService.getMemoryCards());
    }, []),
  );

  return (
    <View style={styles.container}>
      <View style={[styles.header, { paddingTop: insets.top + spacing.sm }]}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backBtnText}>‹</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>念想卡片</Text>
        <View style={{ width: 40 }} />
      </View>

      {cards.length === 0 ? (
        <View style={styles.empty}>
          <Text style={styles.emptyIcon}>🌙</Text>
          <Text style={styles.emptyText}>还没有念想卡片</Text>
          <Text style={styles.emptySubtext}>完成一次对话后，卡片会出现在这里</Text>
        </View>
      ) : (
        <FlatList
          data={cards}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          renderItem={({ item }) => (
            <View style={styles.card}>
              <Text style={styles.cardDate}>{item.date}</Text>
              <Text style={styles.cardTitle}>{item.title}</Text>
              <View style={styles.divider} />
              <Text style={styles.cardLabel}>💭 原来的想法</Text>
              <Text style={styles.cardContent}>{item.originalThought}</Text>
              <Text style={styles.cardLabel}>🌱 新的视角</Text>
              <Text style={styles.cardContent}>{item.newPerspective}</Text>
              <Text style={styles.cardLabel}>🎯 这周试试</Text>
              <Text style={styles.cardContent}>{item.microAction}</Text>
              {item.reflection ? (
                <>
                  <Text style={styles.cardLabel}>🤔 留给你</Text>
                  <Text style={styles.cardContent}>{item.reflection}</Text>
                </>
              ) : null}
            </View>
          )}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background.base },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.md,
    paddingBottom: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border.DEFAULT,
  },
  backBtn: { width: 40, alignItems: 'center' },
  backBtnText: { fontSize: 28, color: colors.text.primary, lineHeight: 32 },
  headerTitle: {
    fontSize: typography.size.lg,
    fontWeight: typography.weight.semibold as any,
    color: colors.text.primary,
  },
  empty: { flex: 1, justifyContent: 'center', alignItems: 'center', gap: spacing.md },
  emptyIcon: { fontSize: 48 },
  emptyText: { fontSize: typography.size.lg, color: colors.text.secondary },
  emptySubtext: { fontSize: typography.size.sm, color: colors.text.tertiary },
  list: { padding: spacing.lg, gap: spacing.lg },
  card: {
    backgroundColor: colors.background.surface,
    borderRadius: borderRadius.xl,
    padding: spacing.xl,
    borderWidth: 1,
    borderColor: colors.border.DEFAULT,
  },
  cardDate: { fontSize: typography.size.xs, color: colors.text.tertiary, marginBottom: spacing.xs },
  cardTitle: {
    fontSize: typography.size.lg,
    fontWeight: typography.weight.semibold as any,
    color: colors.text.primary,
    marginBottom: spacing.md,
  },
  divider: { height: 1, backgroundColor: colors.border.DEFAULT, marginBottom: spacing.md },
  cardLabel: { fontSize: typography.size.sm, color: colors.text.tertiary, marginBottom: spacing.xs },
  cardContent: {
    fontSize: typography.size.md,
    color: colors.text.secondary,
    marginBottom: spacing.md,
    lineHeight: typography.lineHeight.relaxed * typography.size.md,
  },
});

export default HistoryScreen;
