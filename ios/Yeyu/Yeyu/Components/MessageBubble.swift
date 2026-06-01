import SwiftUI

/// 对话气泡组件
/// 用户（右）：橙色渐变填充，深色文字
/// AI（左）：液态玻璃填充，亮色文字，带 AI 头像
struct MessageBubble: View {

    enum Sender { case user, ai }

    let content: String
    let sender: Sender
    var isLoading: Bool = false

    private var isUser: Bool { sender == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: Yeyu.Spacing.sm) {
            // 用户消息右对齐：左侧留白
            if isUser { Spacer(minLength: 64) }

            // AI 头像（28pt 圆形光球）
            if !isUser {
                AIOrbAvatar()
            }

            // 气泡
            bubbleContent
                .padding(.horizontal, Yeyu.Spacing.base)
                .padding(.vertical, Yeyu.Spacing.md)
                .background(bubbleBackground)
                .clipShape(bubbleShape)

            // AI 消息左对齐：右侧留白
            if !isUser { Spacer(minLength: 64) }
        }
        .padding(.horizontal, Yeyu.Spacing.base)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var bubbleContent: some View {
        if isLoading {
            TypingIndicator()
        } else {
            Text(content)
                .font(Yeyu.Typography.body)
                .lineSpacing(Yeyu.Typography.bodyLineSpacing)
                .foregroundColor(isUser ? Color.YY.background : Color.YY.textPrimary)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            LinearGradient(
                colors: [Color.YY.glowPrimary, Color.YY.glowSecondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.YY.lgFill
                .overlay(
                    bubbleShape
                        .strokeBorder(Color.YY.lgStroke, lineWidth: 0.5)
                )
        }
    }

    private var bubbleShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Yeyu.Radius.bubble, style: .continuous)
    }
}

// MARK: - AI Orb Avatar

private struct AIOrbAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.YY.glowPrimary.opacity(0.9),
                            Color.YY.glowSecondary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Circle()
                .fill(Color.YY.lgSpecular)
                .frame(width: 10, height: 10)
                .offset(x: -5, y: -5)
                .blur(radius: 3)

            Text("夜")
                .font(Yeyu.Typography.label)
                .foregroundColor(.white)
        }
        .frame(width: 28, height: 28)
        .accessibilityHidden(true)
    }
}

// MARK: - Typing Indicator（AI 思考中动效）

private struct TypingIndicator: View {
    @State private var bouncing: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.YY.textSecondary)
                    .frame(width: 6, height: 6)
                    .offset(y: bouncing ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.18),
                        value: bouncing
                    )
            }
        }
        .frame(height: 20)
        .onAppear { bouncing = true }
        .accessibilityLabel("AI 正在输入")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Card Preview Bubble（行动卡片气泡）
// 占位：完整卡片 UI 在后续 Issue 实现

struct CardBubble: View {
    let thought: String
    let reframe: String
    let actions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Yeyu.Spacing.md) {
            // 标题
            HStack(spacing: Yeyu.Spacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.YY.glowPrimary)
                Text("今晚的行动卡片")
                    .font(Yeyu.Typography.label)
                    .foregroundColor(Color.YY.textSecondary)
                    .textCase(.uppercase)
                    .kerning(0.5)
            }

            Divider()
                .overlay(Color.YY.lgStroke)

            // Thought
            VStack(alignment: .leading, spacing: Yeyu.Spacing.xs) {
                Text("脑海里的声音")
                    .font(Yeyu.Typography.caption)
                    .foregroundColor(Color.YY.textSecondary)
                Text(thought)
                    .font(Yeyu.Typography.body)
                    .foregroundColor(Color.YY.textPrimary)
                    .lineSpacing(Yeyu.Typography.bodyLineSpacing)
            }

            // Reframe
            VStack(alignment: .leading, spacing: Yeyu.Spacing.xs) {
                Text("换个角度看")
                    .font(Yeyu.Typography.caption)
                    .foregroundColor(Color.YY.glowPrimary)
                Text(reframe)
                    .font(Yeyu.Typography.body)
                    .foregroundColor(Color.YY.textPrimary)
                    .lineSpacing(Yeyu.Typography.bodyLineSpacing)
            }

            // Actions
            VStack(alignment: .leading, spacing: Yeyu.Spacing.sm) {
                Text("今晚可以做")
                    .font(Yeyu.Typography.caption)
                    .foregroundColor(Color.YY.textSecondary)
                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    HStack(alignment: .top, spacing: Yeyu.Spacing.sm) {
                        Circle()
                            .fill(Color.YY.glowPrimary)
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                        Text(action)
                            .font(Yeyu.Typography.body)
                            .foregroundColor(Color.YY.textPrimary)
                            .lineSpacing(Yeyu.Typography.bodyLineSpacing)
                    }
                }
            }
        }
        .padding(Yeyu.Spacing.xl)
        .liquidGlass(cornerRadius: Yeyu.Radius.card)
        .padding(.horizontal, Yeyu.Spacing.base)
    }
}

// MARK: - Preview

#Preview("MessageBubble Variants") {
    ScrollView {
        VStack(spacing: Yeyu.Spacing.md) {
            MessageBubble(
                content: "今天工作压力好大，感觉随时要崩了",
                sender: .user
            )
            MessageBubble(
                content: "听起来你今天承受了很多。\n能告诉我，是什么事情让你感觉「随时要崩」？",
                sender: .ai
            )
            MessageBubble(
                content: "我做了个重要提案，结果被全盘否定了，觉得自己什么都不行",
                sender: .user
            )
            MessageBubble(content: "", sender: .ai, isLoading: true)

            CardBubble(
                thought: "我做什么都不行",
                reframe: "这次提案被否定，说明方向还需要调整——这是反馈，不是判决。",
                actions: [
                    "花 10 分钟写下提案被否的 3 个具体原因",
                    "明天找同事聊 5 分钟，听听他们的真实感受"
                ]
            )
        }
        .padding(.vertical, Yeyu.Spacing.xl)
    }
    .background(Color.YY.background)
    .preferredColorScheme(.dark)
}
