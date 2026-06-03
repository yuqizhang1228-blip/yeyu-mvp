import SwiftUI

/// 心情卡片确认流（YUQ-44）
struct ActionCardSheet: View {
    let card: ParsedActionCard
    /// 已保存后从卡片条点开，仅查看
    var isReviewMode: Bool = false
    let onSave: () -> Void
    let onContinue: () -> Void
    let onDiscard: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
                    Text("今晚的整理")
                        .font(YeyuTypography.title)
                        .foregroundStyle(YeyuColor.textTitle)

                    cardSection(title: "💭 原来的想法", body: card.thought)
                    cardSection(title: "🌱 新的视角", body: card.reframe)

                    if !card.actionItems.isEmpty {
                        VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                            Text("🎯 这周试试")
                                .font(YeyuTypography.footnote)
                                .foregroundStyle(YeyuColor.textTertiary)
                            ForEach(card.actionItems, id: \.self) { item in
                                Text("· \(item)")
                                    .font(YeyuTypography.body)
                                    .foregroundStyle(YeyuColor.textSecondary)
                            }
                        }
                    }

                    if isReviewMode {
                        Button {
                            dismiss()
                        } label: {
                            Text("关闭")
                                .font(YeyuTypography.callout.weight(.semibold))
                                .foregroundStyle(YeyuColor.textInverse)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, YeyuSpacing.lg)
                                .background(YeyuColor.primary)
                                .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                        }
                        .padding(.top, YeyuSpacing.md)
                    } else {
                        VStack(spacing: YeyuSpacing.md) {
                            Button {
                                onSave()
                                dismiss()
                            } label: {
                                Text("保存卡片")
                                    .font(YeyuTypography.callout.weight(.semibold))
                                    .foregroundStyle(YeyuColor.textInverse)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, YeyuSpacing.lg)
                                    .background(YeyuColor.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                            }

                            Button {
                                onContinue()
                                dismiss()
                            } label: {
                                Text("继续聊")
                                    .font(YeyuTypography.callout)
                                    .foregroundStyle(YeyuColor.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, YeyuSpacing.md)
                            }

                            Button(role: .destructive) {
                                onDiscard()
                                dismiss()
                            } label: {
                                Text("放弃这张卡")
                                    .font(YeyuTypography.footnote)
                            }
                        }
                        .padding(.top, YeyuSpacing.md)
                    }
                }
                .padding(YeyuSpacing.xl)
            }
            .background(YeyuColor.backgroundBase)
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
