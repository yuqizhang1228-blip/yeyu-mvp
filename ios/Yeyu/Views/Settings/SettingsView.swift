import SwiftUI
import SwiftData

/// 设置页（YUQ-31）
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @State private var showClearConfirm = false
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var clearError: String?

    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()
            Form {

                // MARK: 个人
                Section("个人") {
                    TextField("昵称", text: $username)
                        .foregroundStyle(YeyuColor.textPrimary)
                }

                // MARK: 功能
                Section("功能") {
                    NavigationLink(destination: PersonalizationView()) {
                        Label("个性化", systemImage: "person.crop.circle")
                    }

                    Button {
                        showFeedback = true
                    } label: {
                        Label("一起共创", systemImage: "lightbulb")
                            .foregroundStyle(YeyuColor.textPrimary)
                    }

                    Link(destination: URL(string: "mailto:hi@yeyu.app")!) {
                        Label("联系我们", systemImage: "envelope")
                            .foregroundStyle(YeyuColor.textPrimary)
                    }

                    HStack {
                        Label("防沉迷提醒", systemImage: "timer")
                            .foregroundStyle(YeyuColor.textTertiary)
                        Spacer()
                        Text("即将推出")
                            .font(YeyuTypography.caption)
                            .foregroundStyle(YeyuColor.textTertiary)
                    }
                }

                // MARK: 偏好
                Section("偏好") {
                    NavigationLink(destination: LanguageView()) {
                        Label("界面语言", systemImage: "globe")
                    }

                    HStack {
                        Label("iCloud 同步", systemImage: "icloud")
                            .foregroundStyle(YeyuColor.textTertiary)
                        Spacer()
                        Text("即将推出")
                            .font(YeyuTypography.caption)
                            .foregroundStyle(YeyuColor.textTertiary)
                    }
                }

                // MARK: 数据
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

                // MARK: 法律
                Section("法律") {
                    Link(destination: URL(string: "https://yeyu-mvp.vercel.app/privacy")!) {
                        Label("隐私条款", systemImage: "lock.shield")
                            .foregroundStyle(YeyuColor.textPrimary)
                    }
                    Link(destination: URL(string: "https://yeyu-mvp.vercel.app/terms")!) {
                        Label("服务条款", systemImage: "doc.text")
                            .foregroundStyle(YeyuColor.textPrimary)
                    }
                }

                // MARK: 关于
                Section("关于") {
                    NavigationLink(destination: AboutView()) {
                        Label("关于夜屿", systemImage: "island.tropical")
                    }
                    LabeledContent("版本", value: "0.1.1 · Night Isle")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFeedback) {
            feedbackSheet
        }
        .confirmationDialog(
            "确认清除所有本地数据？\n包括所有对话记录和行动卡片，无法恢复。",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("清除", role: .destructive) { clearAllData() }
            Button("取消", role: .cancel) {}
        }
    }

    // MARK: 一起共创 sheet
    private var feedbackSheet: some View {
        NavigationStack {
            ZStack {
                YeyuColor.backgroundBase.ignoresSafeArea()
                VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
                    Text("有什么想对夜屿说的？建议、想法、或者任何你觉得重要的事。")
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textSecondary)
                        .lineSpacing(4)
                    TextEditor(text: $feedbackText)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textPrimary)
                        .frame(minHeight: 140)
                        .padding(YeyuSpacing.md)
                        .background(YeyuColor.backgroundSurface)
                        .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                    Spacer()
                }
                .padding(YeyuSpacing.xl)
            }
            .navigationTitle("一起共创")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { showFeedback = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("提交") {
                        // TODO: v1.1 接反馈接口
                        showFeedback = false
                        feedbackText = ""
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func clearAllData() {
        do {
            try DataResetService.clearAll(modelContext: modelContext)
            clearError = nil
            username = ""
        } catch {
            clearError = "清除失败，请稍后重试。"
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
