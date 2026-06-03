import SwiftUI

/// 对话气泡（YUQ-48）
/// 设计稿：Figma `226:2460`（page chat）
struct ChatBubbleView: View {
    let role: MessageRole
    let content: String
    var onRetry: (() -> Void)?

    private var isNetworkError: Bool {
        content == ChatView.networkErrorMessage
    }

    var body: some View {
        HStack {
            if role == .user { Spacer(minLength: 48) }

            VStack(alignment: role == .user ? .trailing : .leading, spacing: YeyuSpacing.sm) {
                if role == .user {
                    // 用户气泡：5% 白底 + 右上角直角（其余 12px 圆角）
                    Text(content)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textPrimary)
                        .padding(.horizontal, YeyuSpacing.lg)
                        .padding(.vertical, YeyuSpacing.md)
                        .background(Color.white.opacity(0.05))
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: YeyuRadius.lg,
                                bottomLeadingRadius: YeyuRadius.lg,
                                bottomTrailingRadius: YeyuRadius.lg,
                                topTrailingRadius: 2
                            )
                        )
                } else {
                    // AI 消息：无背景，纯文字
                    Text(content)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textSecondary)
                        .lineSpacing(3)
                }

                if role == .assistant, isNetworkError, let onRetry {
                    Button(action: onRetry) {
                        Text("重试")
                            .font(YeyuTypography.footnote.weight(.semibold))
                            .foregroundStyle(YeyuColor.primary)
                    }
                }
            }

            if role == .assistant { Spacer(minLength: 48) }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatBubbleView(role: .user, content: "最近工作压力很大")
        ChatBubbleView(role: .assistant, content: "听起来你正在经历一段高压期，能跟我说说是什么在压着你吗？")
        ChatBubbleView(role: .assistant, content: ChatView.networkErrorMessage, onRetry: {})
    }
    .padding()
    .background(YeyuColor.backgroundBase)
}
