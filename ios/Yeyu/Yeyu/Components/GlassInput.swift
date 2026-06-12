import SwiftUI

/// 夜屿输入框 — 液态玻璃风格，支持单行/多行
/// Focus 时描边变为橙色（可见焦点，符合 WCAG 无障碍要求）
struct GlassInput: View {
    @Binding var text: String
    var placeholder: String = "说点什么…"
    var axis: Axis = .horizontal
    var maxLines: Int = 6
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: axis == .vertical ? .top : .center, spacing: Yeyu.Spacing.sm) {
            Group {
                if axis == .vertical {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(1...maxLines)
                } else {
                    TextField(placeholder, text: $text)
                        .onSubmit { onSubmit?() }
                }
            }
            .font(Yeyu.Typography.body)
            .foregroundColor(Color.YY.textPrimary)
            .tint(Color.YY.glowPrimary)
            .focused($isFocused)
        }
        .padding(.horizontal, Yeyu.Spacing.base)
        .padding(.vertical, Yeyu.Spacing.md)
        .background(inputBackground)
        .animation(Yeyu.Anim.micro, value: isFocused)
        .accessibilityLabel(placeholder)
    }

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: Yeyu.Radius.card, style: .continuous)
            .fill(Color.YY.lgFill)
            .overlay(
                RoundedRectangle(cornerRadius: Yeyu.Radius.card, style: .continuous)
                    .strokeBorder(
                        isFocused ? Color.YY.ring : Color.YY.lgStroke,
                        lineWidth: isFocused ? 1.5 : 0.5
                    )
                    .shadow(
                        color: isFocused ? Color.YY.glowPrimary.opacity(0.25) : .clear,
                        radius: 8
                    )
            )
    }
}

// MARK: - Chat Input Bar
// 底部对话输入栏：输入框 + 发送按钮组合

struct ChatInputBar: View {
    @Binding var text: String
    var isSending: Bool = false
    var onSend: () -> Void

    @FocusState private var isFocused: Bool

    private var canSend: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending }

    var body: some View {
        HStack(alignment: .bottom, spacing: Yeyu.Spacing.sm) {
            // 多行输入框
            TextField("说点什么…", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .font(Yeyu.Typography.body)
                .foregroundColor(Color.YY.textPrimary)
                .tint(Color.YY.glowPrimary)
                .focused($isFocused)
                .padding(.horizontal, Yeyu.Spacing.base)
                .padding(.vertical, Yeyu.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Yeyu.Radius.card, style: .continuous)
                        .fill(Color.YY.lgFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: Yeyu.Radius.card, style: .continuous)
                                .strokeBorder(
                                    isFocused ? Color.YY.ring : Color.YY.lgStroke,
                                    lineWidth: isFocused ? 1.5 : 0.5
                                )
                        )
                )
                .animation(Yeyu.Anim.micro, value: isFocused)
                .accessibilityLabel("输入消息")

            // 发送按钮（44×44pt 触控目标）
            Button {
                guard canSend else { return }
                onSend()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            canSend
                            ? LinearGradient(
                                colors: [Color.YY.glowPrimary, Color.YY.glowSecondary],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [Color.YY.lgFillElevated, Color.YY.lgFillElevated],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                              )
                        )
                        .frame(width: 44, height: 44)

                    if isSending {
                        ProgressView()
                            .tint(canSend ? Color.YY.background : Color.YY.textSecondary)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(canSend ? Color.YY.background : Color.YY.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .animation(Yeyu.Anim.micro, value: canSend)
            .accessibilityLabel(isSending ? "发送中" : "发送")
        }
        .padding(.horizontal, Yeyu.Spacing.base)
        .padding(.vertical, Yeyu.Spacing.md)
        .background(
            Color.YY.lgFill
                .overlay(
                    Color.YY.lgStrokeSoft
                        .frame(height: 0.5),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Preview

#Preview("GlassInput") {
    VStack(spacing: Yeyu.Spacing.xl) {
        GlassInput(text: .constant(""), placeholder: "说点什么…")
        GlassInput(text: .constant("今天工作压力特别大，感觉撑不住了"), axis: .vertical)

        Spacer()

        ChatInputBar(text: .constant(""), onSend: {})
        ChatInputBar(text: .constant("今天感觉很累"), onSend: {})
        ChatInputBar(text: .constant(""), isSending: true, onSend: {})
    }
    .padding(Yeyu.Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.YY.background)
    .preferredColorScheme(.dark)
}
