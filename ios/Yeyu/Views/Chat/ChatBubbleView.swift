import SwiftUI

/// 对话气泡（YUQ-32 / YUQ-48）
/// 设计稿：Figma `226:2460`（page chat）
/// - 用户：白 5% 底胶囊（右上直角）。
/// - AI：无底纯文本，**Markdown 渲染**——正文 14pt 白，小标题 18pt Medium 白，段落留白（226:2476）。
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
                    Text(content)
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
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
                    AssistantMarkdownText(content: content)
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

/// AI 文本的轻量 Markdown 渲染：小标题（# / ## / ###）、无序列表（- / *）、段落、行内 **加粗**。
/// 字号/字色严格对齐 226:2476：正文 14pt 白、小标题 18pt Medium 白、行距 ~1.5。
struct AssistantMarkdownText: View {
    let content: String

    private enum Block: Identifiable {
        case heading(String)
        case bullet(String)
        case paragraph(String)
        var id: String {
            switch self {
            case .heading(let s): return "h:\(s)"
            case .bullet(let s): return "b:\(s)"
            case .paragraph(let s): return "p:\(s)"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.md) {
            ForEach(blocks) { block in
                switch block {
                case .heading(let text):
                    inline(text)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                case .bullet(let text):
                    HStack(alignment: .top, spacing: YeyuSpacing.sm) {
                        Text("·").font(.system(size: 14)).foregroundStyle(.white)
                        inline(text)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                case .paragraph(let text):
                    inline(text)
                        .font(.system(size: 14))
                        .tracking(0.14)
                        .foregroundStyle(.white)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 行内 Markdown（**加粗** / *斜体*）；解析失败回退纯文本。
    private func inline(_ s: String) -> Text {
        if let attr = try? AttributedString(
            markdown: s,
            options: AttributedString.MarkdownParsingOptions(
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        ) {
            return Text(attr)
        }
        return Text(s)
    }

    private var blocks: [Block] {
        var result: [Block] = []
        var paragraph: [String] = []

        func flush() {
            if !paragraph.isEmpty {
                result.append(.paragraph(paragraph.joined(separator: "\n")))
                paragraph.removeAll()
            }
        }

        for rawLine in content.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                flush()
            } else if let heading = headingText(line) {
                flush()
                result.append(.heading(heading))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                flush()
                result.append(.bullet(String(line.dropFirst(2))))
            } else {
                paragraph.append(line)
            }
        }
        flush()
        return result.isEmpty ? [.paragraph(content)] : result
    }

    private func headingText(_ line: String) -> String? {
        guard line.hasPrefix("#") else { return nil }
        let stripped = line.drop(while: { $0 == "#" })
        guard stripped.first == " " else { return nil }
        return stripped.trimmingCharacters(in: .whitespaces)
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatBubbleView(role: .user, content: "最近工作压力很大")
        ChatBubbleView(role: .assistant, content: "听起来你正独自漂浮在一片寂静又冷清的海域。🌊\n\n## 认知行为疗法中的孤立感\n\n这种孤立常伴随**自动思维**，比如“没人理解我”。\n\n## 分享你的感受\n\n试着捕捉此刻最让你难受的瞬间，告诉我你的感受。✨")
        ChatBubbleView(role: .assistant, content: ChatView.networkErrorMessage, onRetry: {})
    }
    .padding()
    .background(YeyuColor.backgroundBase)
}
