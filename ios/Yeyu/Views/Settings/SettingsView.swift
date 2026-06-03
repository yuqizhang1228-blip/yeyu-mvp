import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @State private var memoryNote = ""
    @State private var showClearConfirm = false
    @State private var clearError: String?

    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()
            Form {
                Section("个人") {
                    TextField("昵称", text: $username)
                    LabeledContent("用户 ID", value: YeyuUser.ensureUserId())
                        .font(YeyuTypography.caption)
                }
                Section {
                    Text("写下你希望夜屿记住的一小段自我描述（可选）")
                        .font(YeyuTypography.footnote)
                        .foregroundStyle(YeyuColor.textTertiary)
                    TextEditor(text: $memoryNote)
                        .frame(minHeight: 88)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textPrimary)
                } header: {
                    Text("本地记忆")
                } footer: {
                    Text("仅存在本机，用于让 Chip 更贴近你；可在「清除所有数据」时一并删除。")
                        .font(YeyuTypography.caption)
                }
                Section("数据") {
                    Button("清除所有数据", role: .destructive) {
                        showClearConfirm = true
                    }
                    if let clearError {
                        Text(clearError)
                            .font(YeyuTypography.caption)
                            .foregroundStyle(YeyuColor.error)
                    }
                }
                Section("关于") {
                    LabeledContent("版本", value: "0.1.1 (SwiftUI)")
                    Text("夜屿 · 情绪梳理工具，不替代专业咨询。")
                        .font(YeyuTypography.footnote)
                        .foregroundStyle(YeyuColor.textTertiary)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            memoryNote = UserProfileService.load().manualNote
        }
        .onChange(of: memoryNote) { _, newValue in
            var profile = UserProfileService.load()
            profile.manualNote = newValue
            UserProfileService.save(profile)
        }
        .confirmationDialog(
            "确认清除所有本地数据？\n包括所有对话记录和行动卡片，无法恢复。",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("清除", role: .destructive) {
                clearAllData()
            }
            Button("取消", role: .cancel) {}
        }
    }

    private func clearAllData() {
        do {
            try DataResetService.clearAll(modelContext: modelContext)
            clearError = nil
            username = ""
            memoryNote = ""
        } catch {
            clearError = "清除失败，请稍后重试。"
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
