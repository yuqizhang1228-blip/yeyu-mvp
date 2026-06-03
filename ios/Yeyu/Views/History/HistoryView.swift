import SwiftUI
import SwiftData

/// 行动卡片列表（YUQ-36）— 进行中 / 已完成 双 Tab
struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoryCard.createdAt, order: .reverse) private var cards: [MemoryCard]
    @State private var selectedCard: MemoryCard?
    @State private var showCompleted = false

    private var activeCards: [MemoryCard]    { cards.filter { !$0.isCompleted } }
    private var completedCards: [MemoryCard] { cards.filter {  $0.isCompleted } }
    private var displayCards: [MemoryCard]   { showCompleted ? completedCards : activeCards }

    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Tab 切换 ──────────────────────────────
                Picker("", selection: $showCompleted) {
                    Text("进行中 \(activeCards.isEmpty ? "" : "(\(activeCards.count))")").tag(false)
                    Text("已完成 \(completedCards.isEmpty ? "" : "(\(completedCards.count))")").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.vertical, YeyuSpacing.md)

                // ── 卡片列表 ──────────────────────────────
                if displayCards.isEmpty {
                    Spacer()
                    Text(showCompleted ? "还没有完成的卡片" : "还没有保存的卡片")
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textTertiary)
                    Spacer()
                } else {
                    List {
                        ForEach(displayCards) { card in
                            Button {
                                selectedCard = card
                            } label: {
                                cardRow(card)
                            }
                            .listRowBackground(YeyuColor.backgroundSurface)
                            // 右滑：删除
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(card)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            // 左滑：标记完成 / 撤销完成
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    withAnimation { card.isCompleted.toggle() }
                                    try? modelContext.save()
                                } label: {
                                    Label(
                                        card.isCompleted ? "撤销完成" : "标记完成",
                                        systemImage: card.isCompleted ? "arrow.uturn.backward" : "checkmark.circle"
                                    )
                                }
                                .tint(card.isCompleted ? YeyuColor.textTertiary : YeyuColor.primary)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("行动卡片")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedCard) { card in
            MemoryCardDetailSheet(card: card) {
                selectedCard = nil
                appState.openChatFromHistory(sessionId: card.sessionId)
            }
        }
    }

    @ViewBuilder
    private func cardRow(_ card: MemoryCard) -> some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
            HStack {
                Text(card.title)
                    .font(YeyuTypography.callout.weight(.semibold))
                    .foregroundStyle(card.isCompleted ? YeyuColor.textTertiary : YeyuColor.textTitle)
                    .strikethrough(card.isCompleted, color: YeyuColor.textTertiary)
                Spacer()
                if card.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(YeyuColor.primary.opacity(0.6))
                }
            }
            Text(card.thought)
                .font(YeyuTypography.footnote)
                .foregroundStyle(card.isCompleted ? YeyuColor.textTertiary : YeyuColor.textSecondary)
                .lineLimit(2)
            Text(card.reframe)
                .font(YeyuTypography.footnote)
                .foregroundStyle(YeyuColor.textTertiary)
                .lineLimit(1)
        }
        .opacity(card.isCompleted ? 0.6 : 1)
    }
}

#Preview {
    NavigationStack { HistoryView() }
        .environment(AppState())
}
