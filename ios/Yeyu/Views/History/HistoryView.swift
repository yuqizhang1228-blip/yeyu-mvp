import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

/// 心情/行动卡片页（YUQ-36）— 进行中 / 已完成 双 Tab
/// 设计稿：Figma `226:2291`（进行中）、`253:614`（已完成）。卡片为玻璃卡 + 「去完成」。
/// 命名沿用 App 术语「行动卡片」（与抽屉入口一致），稿子标题为「心情卡片」。
struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MemoryCard.createdAt, order: .reverse) private var cards: [MemoryCard]
    @State private var selectedCard: MemoryCard?
    @State private var showCompleted = false

    private var activeCards: [MemoryCard]    { cards.filter { !$0.isCompleted } }
    private var completedCards: [MemoryCard] { cards.filter {  $0.isCompleted } }
    private var displayCards: [MemoryCard]   { showCompleted ? completedCards : activeCards }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [YeyuColor.background0515Top, YeyuColor.backgroundDrawer],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                tabBar
                content
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedCard) { card in
            MemoryCardDetailSheet(card: card) {
                selectedCard = nil
                appState.openChatFromHistory(sessionId: card.sessionId)
            }
        }
    }

    // MARK: 顶栏（226:2318 · 返回 + 居中标题）

    private var header: some View {
        ZStack {
            Text("行动卡片")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("返回")
                Spacer()
            }
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .frame(height: 46)
    }

    // MARK: 文字 Tab + 下划线（226:2324/2325/2326）

    private var tabBar: some View {
        HStack(spacing: YeyuSpacing.xxl) {
            tab(title: "进行中", isActive: !showCompleted) { showCompleted = false }
            tab(title: "已完成", isActive: showCompleted) { showCompleted = true }
            Spacer()
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.top, YeyuSpacing.md)
        .padding(.bottom, YeyuSpacing.lg)
    }

    private func tab(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: isActive ? .medium : .regular))
                    .foregroundStyle(isActive ? .white : Color.white.opacity(0.4))
                Capsule()
                    .fill(isActive ? Color.white : .clear)
                    .frame(width: 30, height: 2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isActive)
    }

    // MARK: 内容

    @ViewBuilder
    private var content: some View {
        if displayCards.isEmpty {
            Spacer()
            Text(showCompleted ? "还没有完成的卡片" : "还没有保存的卡片")
                .font(YeyuTypography.body)
                .foregroundStyle(YeyuColor.textTertiary)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: YeyuSpacing.lg) {
                    ForEach(displayCards) { card in
                        cardView(card)
                    }
                }
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.top, YeyuSpacing.xs)
                .padding(.bottom, YeyuSpacing.xxxl)
            }
        }
    }

    // MARK: 单卡（226:2294 · 玻璃卡）

    private func cardView(_ card: MemoryCard) -> some View {
        Button {
            selectedCard = card
        } label: {
            VStack(alignment: .leading, spacing: YeyuSpacing.md) {
                Text("“\(card.title)")
                    .font(YeyuTypography.footnote)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .lineLimit(1)

                Text(primaryAction(card))
                    .font(YeyuTypography.callout)
                    .foregroundStyle(.white)
                    .lineSpacing(5)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: YeyuSpacing.md)

                HStack(alignment: .bottom) {
                    Text(dateLabel(card.createdAt))
                        .font(YeyuTypography.footnote)
                        .foregroundStyle(Color.white.opacity(0.3))
                    Spacer()
                    completeControl(card)
                }
            }
            .padding(YeyuSpacing.xl)
            .frame(minHeight: 140, alignment: .topLeading)
            .background { cardSurface }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                withAnimation { modelContext.delete(card); try? modelContext.save() }
            } label: { Label("删除", systemImage: "trash") }
        }
    }

    /// 玻璃卡底：iOS 26 暗色 Liquid Glass；更低版本暗底 + ultraThinMaterial。对齐 #2C2C2C@70% + blur32。
    @ViewBuilder
    private var cardSurface: some View {
        let shape = RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
        if #available(iOS 26.0, *) {
            shape
                .fill(.clear)
                .glassEffect(
                    .regular.tint(YeyuColor.backgroundSheet.opacity(0.55)),
                    in: shape
                )
        } else {
            shape
                .fill(YeyuColor.backgroundSheet.opacity(0.85))
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }

    /// 「去完成」白胶囊（进行中）/「✓ 已完成」（已完成，点按可撤销）。
    @ViewBuilder
    private func completeControl(_ card: MemoryCard) -> some View {
        if card.isCompleted {
            Button {
                toggleComplete(card)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                    Text("已完成")
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color.white.opacity(0.7))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("已完成，点按撤销")
        } else {
            Button {
                toggleComplete(card)
            } label: {
                Text("去完成")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.black.opacity(0.8))
                    .padding(.horizontal, YeyuSpacing.lg)
                    .frame(height: 30)
                    .background(Color.white, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: 逻辑

    private func primaryAction(_ card: MemoryCard) -> String {
        card.displayActions.first ?? card.reframe
    }

    private func toggleComplete(_ card: MemoryCard) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        withAnimation(.easeInOut(duration: 0.25)) {
            card.isCompleted.toggle()
        }
        try? modelContext.save()
    }

    private func dateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack { HistoryView() }
        .environment(AppState())
}
