import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 0515 玻璃输入框（Figma `414:2187` 对话 / `411:2006` 首页）。
/// - 内边距 12 · 圆角 24 · 文案/icon 行间距 19
/// - 左 `InputIconModel` · 右 `InputIconVoice`（有文案时可切发送箭头，保留白圆底）
struct YeyuInputBox: View {
    @Binding var text: String
    var placeholder: String
    var focus: FocusState<Bool>.Binding
    var isLoading: Bool = false
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)? = nil
    var onSend: () -> Void
    /// 空态点按右侧 icon（首页聚焦输入；对话页可省略）
    var onVoiceTapWhenEmpty: (() -> Void)? = nil

    private var hasInput: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.inputBoxRowGap) {
            textField
            iconRow
        }
        .padding(YeyuSpacing.md)
        .yeyuInputBoxGlass(cornerRadius: YeyuRadius.promptCard)
    }

    private var textField: some View {
        Group {
            if let onSubmit {
                field
                    .onSubmit(onSubmit)
            } else {
                field
            }
        }
    }

    private var field: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundStyle(YeyuColor.textPlaceholder0515),
            axis: .vertical
        )
        .lineLimit(1...4)
        .font(YeyuTypography.body)
        .lineSpacing(YeyuTypography.bodyInputLineSpacing)
        .foregroundStyle(.white)
        .tint(YeyuColor.primary)
        .focused(focus)
        .submitLabel(submitLabel)
        .frame(minHeight: 22, alignment: .topLeading)
    }

    private var iconRow: some View {
        HStack(spacing: 0) {
            YeyuInputModelIcon()
            Spacer(minLength: YeyuSpacing.md)
            trailingAction
        }
    }

    @ViewBuilder
    private var trailingAction: some View {
        Button(action: trailingTap) {
            Group {
                if hasInput {
                    sendGlyph
                } else {
                    YeyuInputVoiceIcon()
                }
            }
            .frame(width: YeyuInputBoxIcon.size, height: YeyuInputBoxIcon.size)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .opacity(isLoading ? 0.4 : 1)
        }
        .disabled(isLoading || (!hasInput && onVoiceTapWhenEmpty == nil))
        .animation(.easeInOut(duration: 0.18), value: hasInput)
        .accessibilityLabel(hasInput ? "发送" : "语音输入")
        .padding(.trailing, -6.5)
    }

    /// 有输入：白圆底 + 上箭头（与 `InputIconVoice` 圆底同色 #F9F9F9）
    private var sendGlyph: some View {
        ZStack {
            Circle()
                .fill(YeyuColor.iconVoiceBackground)
                .frame(width: YeyuInputBoxIcon.size, height: YeyuInputBoxIcon.size)
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(YeyuColor.iconVoiceGlyph)
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func trailingTap() {
        if hasInput {
            onSend()
        } else {
            onVoiceTapWhenEmpty?()
        }
    }
}
