import SwiftUI

/// 心情卡片确认流（YUQ-44）
/// 设计稿：Figma `394:2232`（0515 · 心情卡片弹出）
struct ActionCardSheet: View {
    let card: ParsedActionCard
    /// 已保存后从卡片条点开，仅查看
    var isReviewMode: Bool = false
    let onSave: () -> Void
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // ── 标题 ──────────────────────────────────────────
            Text("行动卡片")
                .font(YeyuTypography.callout.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.top, YeyuSpacing.xl)
                .padding(.bottom, YeyuSpacing.lg)

            // ── 内容区 ────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: YeyuSpacing.xl) {

                    sectionBlock(label: "你的心情", body: card.thought)
                    sectionBlock(label: "换个角度", body: card.reframe)

                    // 行动卡片 hero
                    if !card.actionItems.isEmpty {
                        VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                            Text("明天可以试试")
                                .font(YeyuTypography.footnote)
                                .foregroundStyle(Color.white.opacity(0.6))

                            // 第一条行动：视觉主角
                            Text(card.actionItems[0])
                                .font(YeyuTypography.callout)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, minHeight: 120)
                                .padding(YeyuSpacing.xl)
                                .background(YeyuColor.surfaceActionCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: YeyuRadius.lg)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))

                            // 多余的行动条目（小字补充）
                            ForEach(Array(card.actionItems.dropFirst()), id: \.self) { item in
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

            // ── 按钮区 ────────────────────────────────────────
            if isReviewMode {
                closeButton
                    .padding(.horizontal, YeyuSpacing.xxl)
                    .padding(.bottom, YeyuSpacing.xxl)
            } else {
                HStack(spacing: YeyuSpacing.md) {
                    // 继续聊：描边
                    Button {
                        onContinue()
                        dismiss()
                    } label: {
                        Text("继续聊")
                            .font(YeyuTypography.callout)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .overlay(Capsule().stroke(Color.white.opacity(0.9), lineWidth: 1))
                    }

                    // 保存卡片：实心
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Text("保存卡片")
                            .font(YeyuTypography.callout.weight(.medium))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, YeyuSpacing.xxl)
                .padding(.bottom, YeyuSpacing.xxl)
            }
        }
        .background(YeyuColor.backgroundSheet)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(12)
    }

    // MARK: - 子视图

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

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("关闭")
                .font(YeyuTypography.callout.weight(.medium))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white.opacity(0.9))
                .clipShape(Capsule())
        }
    }
}
