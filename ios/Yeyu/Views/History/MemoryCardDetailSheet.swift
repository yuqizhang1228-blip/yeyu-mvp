import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 行动卡片详情（点开已保存卡片）— 0515 设计语言，与出卡弹窗 `ActionCardSheet`（394:2232）统一。
struct MemoryCardDetailSheet: View {
    let card: MemoryCard
    let onResumeChat: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            Text("行动卡片")
                .font(YeyuTypography.callout.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, YeyuSpacing.xl)
                .padding(.bottom, YeyuSpacing.lg)

            ScrollView {
                VStack(alignment: .leading, spacing: YeyuSpacing.xl) {
                    sectionBlock(label: "你的心情", body: card.thought)
                    sectionBlock(label: "换个角度", body: card.reframe)

                    if !card.displayActions.isEmpty {
                        VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                            Text("明天可以试试")
                                .font(YeyuTypography.footnote)
                                .foregroundStyle(Color.white.opacity(0.6))

                            Text(card.displayActions[0])
                                .font(YeyuTypography.callout)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, minHeight: 120)
                                .padding(YeyuSpacing.xl)
                                .background(YeyuColor.surfaceActionCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: YeyuRadius.xl)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.xl))

                            ForEach(Array(card.displayActions.dropFirst()), id: \.self) { item in
                                Text("· \(item)")
                                    .font(YeyuTypography.footnote)
                                    .foregroundStyle(Color.white.opacity(0.6))
                                    .lineSpacing(4)
                            }
                        }
                    }
                }
                .padding(.horizontal, YeyuSpacing.xxl)
                .padding(.bottom, YeyuSpacing.xl)
            }

            // ── 按钮区（与 ActionCardSheet 一致的胶囊按钮）──────────
            HStack(spacing: YeyuSpacing.md) {
                Button(action: onResumeChat) {
                    Text("回到这场对话")
                        .font(YeyuTypography.callout)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1))
                }

                Button(action: toggleComplete) {
                    Text(card.isCompleted ? "撤销完成" : "标记完成")
                        .font(YeyuTypography.callout.weight(.medium))
                        .foregroundStyle(card.isCompleted ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(card.isCompleted ? Color.white.opacity(0.14) : Color.white.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, YeyuSpacing.xxl)
            .padding(.bottom, YeyuSpacing.xxl)
        }
        .background(YeyuColor.backgroundSheet)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
    }

    private func sectionBlock(label: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.xs) {
            Text(label)
                .font(YeyuTypography.body)
                .foregroundStyle(.white)
            Text(body)
                .font(YeyuTypography.footnote)
                .foregroundStyle(Color.white.opacity(0.6))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func toggleComplete() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        withAnimation(.easeInOut(duration: 0.2)) { card.isCompleted.toggle() }
        try? modelContext.save()
    }
}
