import SwiftUI

/// 个性化（YUQ-37）— 记忆管理 + AI 偏好入口
struct PersonalizationView: View {
    @AppStorage("yeyu_auto_memory") private var autoMemory = true
    @State private var manualNote = ""

    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()
            Form {
                // MARK: 记忆设置
                Section {
                    Toggle("参考保存记忆", isOn: $autoMemory)
                        .tint(YeyuColor.primary)
                } header: {
                    Text("记忆")
                } footer: {
                    Text("开启后，夜屿根据对话自动积累长期记忆，让 Chip 更贴近你。关闭时不自动写入，但可手动编辑。")
                }

                Section {
                    TextEditor(text: $manualNote)
                        .frame(minHeight: 88)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textPrimary)
                } header: {
                    Text("手动记忆笔记")
                } footer: {
                    Text("写下希望夜屿长期记住的事，供 Chip 生成参考，不会出现在对话内容里。")
                }

                // MARK: AI 偏好（v1.1）
                Section {
                    HStack {
                        Text("偏好自定义")
                            .foregroundStyle(YeyuColor.textPrimary)
                        Spacer()
                        Text("即将推出")
                            .font(YeyuTypography.caption)
                            .foregroundStyle(YeyuColor.textTertiary)
                    }
                } header: {
                    Text("AI 偏好")
                } footer: {
                    Text("自定义夜屿的性格特征、回复风格等，将在 v1.1 开放。")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("个性化")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            manualNote = UserProfileService.load().manualNote
        }
        .onChange(of: manualNote) { _, newValue in
            var profile = UserProfileService.load()
            profile.manualNote = newValue
            UserProfileService.save(profile)
        }
    }
}

#Preview {
    NavigationStack { PersonalizationView() }
}
