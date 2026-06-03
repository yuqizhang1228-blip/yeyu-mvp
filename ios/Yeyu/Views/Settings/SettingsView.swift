import SwiftUI
import SwiftData

/// 设置页（YUQ-31）— 大弹窗呈现，对齐 Figma 226:2244
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage(YeyuUser.usernameKey) private var username = ""

    @State private var showPersonalization = false
    @State private var showAbout = false
    @State private var showLanguage = false
    @State private var showFeedback = false
    @State private var feedbackText = ""
    @State private var showClearConfirm = false
    @State private var clearError: String?

    var body: some View {
        VStack(spacing: 0) {
            // ── 顶部栏 ─────────────────────────────────────
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                }
                Spacer()
                Text("设置")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                Spacer()
                // 占位，保证标题居中
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.vertical, 15)

            // ── 内容 ──────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Section 1
                    settingRow(icon: "lightbulb", label: "一起共创") {
                        showFeedback = true
                    }
                    settingRow(icon: "book", label: "关于产品") {
                        showAbout = true
                    }
                    settingRow(icon: "envelope", label: "联系我们") {
                        if let url = URL(string: "mailto:hi@yeyu.app") {
                            UIApplication.shared.open(url)
                        }
                    }

                    sheetDivider()

                    // Section 系统
                    sectionLabel("系统")
                    settingRow(icon: "timer", label: "防沉迷提醒", disabled: true) {}
                    settingRow(icon: "globe", label: "界面语言") {
                        showLanguage = true
                    }

                    sheetDivider()

                    // Section 重要
                    sectionLabel("重要")
                    settingRow(icon: "icloud", label: "iCloud", disabled: true) {}
                    settingRow(icon: "trash", label: "删除本地数据", isDestructive: true) {
                        showClearConfirm = true
                    }
                    if let clearError {
                        Text(clearError)
                            .font(YeyuTypography.caption)
                            .foregroundStyle(YeyuColor.error)
                            .padding(.horizontal, YeyuSpacing.xl)
                    }

                    // Footer
                    VStack(alignment: .leading, spacing: YeyuSpacing.xl) {
                        Link("隐私政策", destination: URL(string: "https://yeyu-mvp.vercel.app/privacy")!)
                        Link("服务条款", destination: URL(string: "https://yeyu-mvp.vercel.app/terms")!)
                        Text("夜屿 1.0")
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.3))
                    .padding(.horizontal, YeyuSpacing.xl)
                    .padding(.top, YeyuSpacing.xxxl)
                    .padding(.bottom, YeyuSpacing.xxl)
                }
            }
        }
        .background(sheetBackground)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        // 二级弹窗
        .sheet(isPresented: $showPersonalization) { PersonalizationView() }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showLanguage) { LanguageView() }
        .sheet(isPresented: $showFeedback) { feedbackSheet }
        .confirmationDialog(
            "确认清除所有本地数据？\n包括所有对话记录和行动卡片，无法恢复。",
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("清除", role: .destructive) { clearAllData() }
            Button("取消", role: .cancel) {}
        }
    }

    // MARK: - 子视图

    private var sheetBackground: some View {
        Color(hex: 0x161616, alpha: 0.92)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }

    private func settingRow(
        icon: String,
        label: String,
        disabled: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        isDestructive ? YeyuColor.error
                        : disabled    ? Color.white.opacity(0.3)
                        : Color.white.opacity(0.8)
                    )
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        isDestructive ? YeyuColor.error
                        : disabled    ? Color.white.opacity(0.3)
                        : .white
                    )
                Spacer()
                if disabled {
                    Text("即将推出")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.3))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.3))
                }
            }
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.vertical, YeyuSpacing.lg)
        }
        .disabled(disabled)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.white.opacity(0.3))
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.vertical, YeyuSpacing.sm)
    }

    private func sheetDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(height: 1)
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.vertical, YeyuSpacing.md)
    }

    // MARK: 一起共创 sheet
    private var feedbackSheet: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
            sheetHeader(title: "一起共创") { showFeedback = false }
            Text("有什么想对夜屿说的？建议、想法、或者你觉得重要的事。")
                .font(YeyuTypography.body)
                .foregroundStyle(Color.white.opacity(0.6))
                .lineSpacing(4)
                .padding(.horizontal, YeyuSpacing.xl)
            TextEditor(text: $feedbackText)
                .font(YeyuTypography.body)
                .foregroundStyle(YeyuColor.textPrimary)
                .frame(minHeight: 140)
                .padding(YeyuSpacing.md)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                .padding(.horizontal, YeyuSpacing.xl)
            HStack {
                Spacer()
                Button("提交") {
                    // TODO: v1.1 接反馈接口
                    showFeedback = false
                    feedbackText = ""
                }
                .font(YeyuTypography.callout.weight(.semibold))
                .foregroundStyle(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white.opacity(0.3) : YeyuColor.primary)
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, YeyuSpacing.xl)
            }
            Spacer()
        }
        .background(sheetBackground)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
    }

    // MARK: 通用 header
    func sheetHeader(title: String, onDismiss: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Text(title)
                .font(.system(size: 18))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, 15)
    }

    // MARK: 清除数据
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
    SettingsView()
}
