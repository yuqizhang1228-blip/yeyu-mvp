import SwiftUI

/// 个性化（YUQ-37）— 大弹窗呈现
struct PersonalizationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("yeyu_auto_memory") private var autoMemory = true
    @State private var manualNote = ""

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── 记忆开关 ─────────────────────────
                    sectionLabel("记忆")
                    HStack {
                        Text("参考保存记忆")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                        Spacer()
                        Toggle("", isOn: $autoMemory)
                            .tint(YeyuColor.primary)
                            .labelsHidden()
                    }
                    .padding(.horizontal, YeyuSpacing.xl)
                    .padding(.vertical, YeyuSpacing.lg)

                    Text("开启后，夜屿根据对话自动积累长期记忆，让 Chip 更贴近你。关闭时不自动写入，但可手动编辑。")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.4))
                        .lineSpacing(4)
                        .padding(.horizontal, YeyuSpacing.xl)
                        .padding(.bottom, YeyuSpacing.lg)

                    sheetDivider()

                    // ── 手动笔记 ─────────────────────────
                    sectionLabel("手动记忆笔记")
                    TextEditor(text: $manualNote)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 100)
                        .padding(YeyuSpacing.md)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                        .padding(.horizontal, YeyuSpacing.xl)
                        .padding(.bottom, YeyuSpacing.sm)

                    Text("写下希望夜屿长期记住的事，供 Chip 生成参考，不会出现在对话里。")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.4))
                        .lineSpacing(4)
                        .padding(.horizontal, YeyuSpacing.xl)
                        .padding(.bottom, YeyuSpacing.lg)

                    sheetDivider()

                    // ── AI 偏好（v1.1）───────────────────
                    sectionLabel("AI 偏好")
                    HStack {
                        Text("偏好自定义")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.white.opacity(0.3))
                        Spacer()
                        Text("即将推出")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.3))
                    }
                    .padding(.horizontal, YeyuSpacing.xl)
                    .padding(.vertical, YeyuSpacing.lg)

                    Text("自定义夜屿的性格特征、回复风格等，将在 v1.1 开放。")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.3))
                        .padding(.horizontal, YeyuSpacing.xl)
                        .padding(.bottom, YeyuSpacing.xxl)
                }
            }
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .onAppear { manualNote = UserProfileService.load().manualNote }
        .onChange(of: manualNote) { _, newValue in
            var profile = UserProfileService.load()
            profile.manualNote = newValue
            UserProfileService.save(profile)
        }
    }

    private var sheetHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Text("个性化")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, 15)
    }

    private var sheetBg: some View {
        Color(hex: 0x161616, alpha: 0.92)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.white.opacity(0.3))
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.top, YeyuSpacing.lg)
            .padding(.bottom, YeyuSpacing.sm)
    }

    private func sheetDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.05))
            .frame(height: 1)
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.vertical, YeyuSpacing.md)
    }
}

#Preview { PersonalizationView() }
