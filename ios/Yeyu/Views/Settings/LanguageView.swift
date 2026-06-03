import SwiftUI

/// 界面语言（YUQ-34）— v1 仅简体中文，多语言 v1.1
struct LanguageView: View {
    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()
            Form {
                Section {
                    HStack {
                        Text("简体中文")
                            .font(YeyuTypography.body)
                            .foregroundStyle(YeyuColor.textPrimary)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundStyle(YeyuColor.primary)
                    }

                    HStack {
                        Text("English")
                            .font(YeyuTypography.body)
                            .foregroundStyle(YeyuColor.textTertiary)
                        Spacer()
                        Text("即将推出")
                            .font(YeyuTypography.caption)
                            .foregroundStyle(YeyuColor.textTertiary)
                    }
                } footer: {
                    Text("v1 仅支持简体中文，多语言将在后续版本开放。")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("界面语言")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { LanguageView() }
}
