import SwiftUI

/// 首次进入昵称设置（对齐 H5 `#nameSetup`）
struct NameSetupView: View {
    @Binding var username: String
    @State private var draft = ""
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.xxl) {
            VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                Text("你好，我是夜屿")
                    .font(YeyuTypography.title)
                    .foregroundStyle(YeyuColor.textTitle)
                Text("在开始之前，你想让我怎么称呼你？")
                    .font(YeyuTypography.body)
                    .foregroundStyle(YeyuColor.textSecondary)
            }

            HStack(spacing: YeyuSpacing.sm) {
                TextField("你的名字", text: $draft)
                    .focused($focused)
                    .font(YeyuTypography.body)
                    .foregroundStyle(YeyuColor.textPrimary)
                    .padding(.horizontal, YeyuSpacing.lg)
                    .padding(.vertical, YeyuSpacing.md)
                    .background(YeyuColor.backgroundInput)
                    .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                    .onSubmit { confirmName() }

                Button(action: confirmName) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(YeyuColor.textInverse)
                        .frame(width: 44, height: 44)
                        .background(YeyuColor.primary)
                        .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                }
                .accessibilityLabel("确认名字")
            }

            Button("跳过") {
                username = YeyuUser.anonymousPlaceholder
            }
            .font(YeyuTypography.footnote)
            .foregroundStyle(YeyuColor.textTertiary)
        }
        .onAppear {
            draft = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                focused = true
            }
        }
    }

    private func confirmName() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        username = trimmed.isEmpty ? YeyuUser.anonymousPlaceholder : trimmed
    }
}
