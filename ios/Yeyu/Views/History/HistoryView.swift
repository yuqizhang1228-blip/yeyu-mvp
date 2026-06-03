import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \MemoryCard.createdAt, order: .reverse) private var cards: [MemoryCard]
    @State private var selectedCard: MemoryCard?

    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()
            if cards.isEmpty {
                Text("还没有保存的卡片")
                    .font(YeyuTypography.body)
                    .foregroundStyle(YeyuColor.textTertiary)
            } else {
                List {
                    ForEach(cards) { card in
                        Button {
                            selectedCard = card
                        } label: {
                            VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                                Text(card.title)
                                    .font(YeyuTypography.callout.weight(.semibold))
                                    .foregroundStyle(YeyuColor.textTitle)
                                Text(card.thought)
                                    .font(YeyuTypography.footnote)
                                    .foregroundStyle(YeyuColor.textSecondary)
                                    .lineLimit(2)
                                Text(card.reframe)
                                    .font(YeyuTypography.footnote)
                                    .foregroundStyle(YeyuColor.textTertiary)
                                    .lineLimit(1)
                            }
                        }
                        .listRowBackground(YeyuColor.backgroundSurface)
                    }
                }
                .scrollContentBackground(.hidden)
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
}

#Preview {
    NavigationStack { HistoryView() }
        .environment(AppState())
}
