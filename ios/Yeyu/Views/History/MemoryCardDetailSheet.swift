import SwiftUI

struct MemoryCardDetailSheet: View {
    let card: MemoryCard
    let onResumeChat: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
                    Text(card.title)
                        .font(YeyuTypography.title)
                        .foregroundStyle(YeyuColor.textTitle)

                    cardSection(title: "你的心情", body: card.thought)
                    cardSection(title: "换个角度", body: card.reframe)

                    if !card.displayActions.isEmpty {
                        VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                            Text("明天可以试试")
                                .font(YeyuTypography.footnote)
                                .foregroundStyle(YeyuColor.textTertiary)
                            ForEach(card.displayActions, id: \.self) { item in
                                Text("· \(item)")
                                    .font(YeyuTypography.body)
                                    .foregroundStyle(YeyuColor.textSecondary)
                            }
                        }
                    }

                    // ── 标记完成 / 撤销 ──────────────────────
                    Button {
                        withAnimation { card.isCompleted.toggle() }
                        try? modelContext.save()
                    } label: {
                        Label(
                            card.isCompleted ? "撤销完成" : "标记完成",
                            systemImage: card.isCompleted ? "arrow.uturn.backward" : "checkmark.circle"
                        )
                        .font(YeyuTypography.callout.weight(.semibold))
                        .foregroundStyle(card.isCompleted ? YeyuColor.textTertiary : YeyuColor.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, YeyuSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: YeyuRadius.lg)
                                .fill(card.isCompleted ? YeyuColor.backgroundSurface : YeyuColor.primaryMuted)
                        )
                    }

                    Button(action: onResumeChat) {
                        Text("回到这场对话")
                            .font(YeyuTypography.callout)
                            .foregroundStyle(YeyuColor.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, YeyuSpacing.md)
                    }

                    Button("关闭") { dismiss() }
                        .font(YeyuTypography.footnote)
                        .foregroundStyle(YeyuColor.textTertiary)
                        .frame(maxWidth: .infinity)
                }
                .padding(YeyuSpacing.xl)
            }
            .background(YeyuColor.backgroundBase)
            .navigationTitle("行动卡片")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func cardSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.xs) {
            Text(title)
                .font(YeyuTypography.footnote)
                .foregroundStyle(YeyuColor.textTertiary)
            Text(body)
                .font(YeyuTypography.body)
                .foregroundStyle(YeyuColor.textPrimary)
                .padding(YeyuSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(YeyuColor.backgroundSurface)
                .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
        }
    }
}
