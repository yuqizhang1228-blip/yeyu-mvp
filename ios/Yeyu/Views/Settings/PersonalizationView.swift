import SwiftUI

/// 个性化（YUQ-37）— 大弹窗呈现，对齐 Figma 226:2802（分组卡：记忆 / 偏好自定义）。
struct PersonalizationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("yeyu_auto_memory") private var autoMemory = true
    @State private var manualNote = ""
    @State private var showMemoryEditor = false
    @State private var showStyleToast = false

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    sectionLabel("记忆")
                    groupCard {
                        toggleRow(label: "参考保存记忆", isOn: $autoMemory)
                        rowDivider
                        navRow(label: "编辑你的记忆") { showMemoryEditor = true }
                    }
                    .padding(.horizontal, YeyuSpacing.xl)

                    sectionLabel("偏好自定义")
                    groupCard {
                        // 沟通风格自定义为 v1.1，占位提示
                        navRow(label: "你希望 AI 有怎样的沟通风格") { showStyleToast = true }
                    }
                    .padding(.horizontal, YeyuSpacing.xl)
                }
                .padding(.bottom, YeyuSpacing.xxl)
            }
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .overlay(alignment: .bottom) {
            if showStyleToast { comingSoonToast }
        }
        .animation(.easeInOut(duration: 0.2), value: showStyleToast)
        .sensoryFeedback(.impact(weight: .light), trigger: showStyleToast)
        .sheet(isPresented: $showMemoryEditor) { memoryEditorSheet }
        .onAppear { manualNote = UserProfileService.load().manualNote }
    }

    // MARK: 分组卡

    private func groupCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: YeyuRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: YeyuRadius.xl)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func toggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(YeyuColor.primary)
                .labelsHidden()
        }
        .padding(.horizontal, YeyuSpacing.lg)
        .frame(height: 52)
    }

    private func navRow(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.3))
            }
            .padding(.horizontal, YeyuSpacing.lg)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .padding(.leading, YeyuSpacing.lg)
    }

    private var comingSoonToast: some View {
        Text("敬请期待")
            .font(YeyuTypography.footnote)
            .foregroundStyle(.white)
            .padding(.horizontal, YeyuSpacing.lg)
            .padding(.vertical, YeyuSpacing.sm + 2)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 48)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .task(id: showStyleToast) {
                guard showStyleToast else { return }
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                showStyleToast = false
            }
    }

    // MARK: 编辑你的记忆（保留手动记忆功能）

    private var memoryEditorSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button { showMemoryEditor = false } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                }
                Spacer()
                Text("编辑你的记忆").font(.system(size: 18)).foregroundStyle(.white)
                Spacer()
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.vertical, 15)

            Text("写下希望夜屿长期记住的事，供 Chip 生成参考，不会出现在对话里。")
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.4))
                .lineSpacing(4)
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.bottom, YeyuSpacing.md)

            TextEditor(text: $manualNote)
                .font(YeyuTypography.body)
                .foregroundStyle(YeyuColor.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 160)
                .padding(YeyuSpacing.md)
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: YeyuRadius.lg))
                .padding(.horizontal, YeyuSpacing.xl)

            Spacer()
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .onChange(of: manualNote) { _, newValue in
            var profile = UserProfileService.load()
            profile.manualNote = newValue
            UserProfileService.save(profile)
        }
    }

    // MARK: 通用

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
            .padding(.top, YeyuSpacing.xl)
            .padding(.bottom, YeyuSpacing.sm)
    }
}

#Preview { PersonalizationView() }
