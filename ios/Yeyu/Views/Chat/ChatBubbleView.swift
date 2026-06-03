import SwiftUI

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
                Text(content)
                    .font(YeyuTypography.body)
                    .foregroundStyle(role == .user ? YeyuColor.textPrimary : YeyuColor.textSecondary)
                    .padding(.horizontal, YeyuSpacing.lg)
                    .padding(.vertical, YeyuSpacing.md)
                    .background(role == .user ? YeyuColor.backgroundSurface : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))

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
    VStack {
        ChatBubbleView(role: .user, content: "最近工作压力很大")
        ChatBubbleView(role: .assistant, content: ChatView.networkErrorMessage, onRetry: {})
    }
    .padding()
    .background(YeyuColor.backgroundBase)
}
