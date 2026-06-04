import SwiftUI

/// 首页（YUQ-27 高保真 · Figma 0515 `page/home` 411:1996）
/// 结构：背景插画 + 渐变 → 顶栏 → 两行问候 → 横向快捷话题 → 玻璃输入框 → 合规一行。
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @State private var input = ""
    @State private var chipLabels: [String] = []
    @State private var chipsLoading = true
    @FocusState private var inputFocused: Bool

    private var needsNameSetup: Bool {
        YeyuUser.needsNameSetup(stored: username)
    }

    private var hasInput: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack(alignment: .leading) {
            background

            if needsNameSetup {
                ScrollView {
                    NameSetupView(username: $username)
                        .padding(.horizontal, YeyuSpacing.xl)
                        .padding(.top, YeyuSpacing.xxxl)
                }
            } else {
                homeContent
            }

            SideDrawerView()
        }
        .navigationBarHidden(true)
        .task(id: needsNameSetup) {
            guard !needsNameSetup else { return }
            _ = YeyuUser.ensureUserId()
            UserProfileService.recordVisit()
            await loadChips()
        }
    }

    // MARK: 背景（411:1997 渐变 + bg-image 插画）

    private var background: some View {
        LinearGradient(
            colors: [YeyuColor.background0515Top, YeyuColor.background0515Bottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            Image("HomeHeroBackground")
                .resizable()
                .scaledToFill()
        )
        .ignoresSafeArea()
    }

    // MARK: 主内容

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            navBar
            greeting
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.top, YeyuSpacing.xxl)

            Spacer(minLength: YeyuSpacing.xxl)

            chipSection
                .padding(.bottom, YeyuSpacing.lg)

            inputBox
                .padding(.horizontal, YeyuSpacing.xl)

            compliance
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.top, YeyuSpacing.md)
        }
        .contentShape(Rectangle())
        .onTapGesture { inputFocused = false }
    }

    // MARK: 顶栏（411:2021 · Menu Icon 411:2022）

    private var navBar: some View {
        HStack {
            Button {
                inputFocused = false
                appState.openDrawer()
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Rectangle().frame(width: 20, height: 1.5)
                    Rectangle().frame(width: 14, height: 1.5)
                    Rectangle().frame(width: 20, height: 1.5)
                }
                .foregroundStyle(YeyuColor.textTitle)
                .frame(width: 44, height: 44, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("打开菜单")
            Spacer()
        }
        .frame(height: 50)
        .padding(.horizontal, YeyuSpacing.xl)
    }

    // MARK: 问候（411:2003 · 主标题 26pt / 副标题 12pt Light 80%）

    private var greeting: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(timeGreeting + "，")
                    .font(YeyuTypography.displayGreeting)
                    .tracking(0.52)
                    .foregroundStyle(YeyuColor.textTitle)
                if let name = YeyuUser.displayName(stored: username) {
                    Text("\(name)，今晚想聊点什么？")
                        .font(YeyuTypography.displayGreeting)
                        .tracking(0.52)
                        .foregroundStyle(YeyuColor.textTitle)
                } else {
                    Text("欢迎来到夜屿。")
                        .font(YeyuTypography.displayGreeting)
                        .tracking(0.52)
                        .foregroundStyle(YeyuColor.textTitle)
                }
            }
            Text("在这里分享你的困惑，我来帮你梳理思绪。")
                .font(YeyuTypography.footnote.weight(.light))
                .tracking(0.48)
                .foregroundStyle(YeyuColor.textOnDarkSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<9:  return "早上好"
        case 9..<12: return "上午好"
        case 12..<17: return "下午好"
        case 17..<19: return "傍晚好"
        case 19..<23: return "晚上好"
        default:     return "夜深了"
        }
    }

    // MARK: 横向快捷话题（411:2024 · card/chat-prompt 161×74）

    @ViewBuilder
    private var chipSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: YeyuSpacing.sm) {
                if chipsLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        promptCardBackground
                            .frame(width: 200, height: 74)
                            .redacted(reason: .placeholder)
                    }
                } else {
                    ForEach(chipLabels, id: \.self) { text in
                        Button { startChat(with: text) } label: {
                            Text(text)
                                .font(YeyuTypography.body)
                                .lineSpacing(3)
                                .foregroundStyle(YeyuColor.textOnDarkSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(width: 168, height: 42, alignment: .topLeading)
                                .padding(YeyuSpacing.lg)
                                .background(promptCardBackground)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, YeyuSpacing.xl)
        }
        .scrollClipDisabled()
    }

    private var promptCardBackground: some View {
        RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
            .fill(YeyuColor.surfacePromptCard)
            .overlay(
                RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                    .stroke(YeyuColor.borderPromptCard, lineWidth: 1)
            )
    }

    // MARK: 玻璃输入框（411:2006）

    private var inputBox: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
            TextField(
                "",
                text: $input,
                prompt: Text("随便聊聊...").foregroundStyle(YeyuColor.textPlaceholder0515),
                axis: .vertical
            )
            .lineLimit(1...4)
            .font(YeyuTypography.body)
            .foregroundStyle(.white)
            .tint(YeyuColor.primary)
            .focused($inputFocused)
            .submitLabel(.send)
            .onSubmit { startChat(with: input) }
            .frame(minHeight: 22, alignment: .topLeading)

            HStack(spacing: 0) {
                modelIcon
                Spacer(minLength: YeyuSpacing.md)
                voiceOrSendButton
            }
        }
        .padding(YeyuSpacing.md)
        .yeyuGlass(cornerRadius: YeyuRadius.promptCard, interactive: true)
    }

    /// 模型 icon（411:2008）· 当前为占位视觉，模型切换为非 P0
    private var modelIcon: some View {
        ZStack {
            Circle().fill(YeyuColor.iconModelBackground)
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(YeyuColor.iconModelGlyph)
        }
        .frame(width: 31, height: 31)
        .accessibilityHidden(true)
    }

    /// 语音 icon（411:2013）· 有输入切为发送；空态点按聚焦输入框（语音为非 P0）。
    private var voiceOrSendButton: some View {
        Button {
            if hasInput {
                startChat(with: input)
            } else {
                inputFocused = true
            }
        } label: {
            ZStack {
                Circle().fill(YeyuColor.iconVoiceBackground)
                Group {
                    if hasInput {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(YeyuColor.iconVoiceGlyph)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        VoiceWaveform(color: YeyuColor.iconVoiceGlyph)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(width: 31, height: 31)
            // 触控目标补足到 44pt（MASTER §3.5 / 技能 Touch Target）
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .animation(.easeInOut(duration: 0.18), value: hasInput)
        .accessibilityLabel(hasInput ? "发送" : "语音输入")
        // 抵消 44pt 触控区带来的额外右侧外扩，使圆形视觉贴右（(44-31)/2 = 6.5）
        .padding(.trailing, -6.5)
    }

    // MARK: 合规一行（411:2001）

    private var compliance: some View {
        Text("本功能无法代替专业心理咨询或医学治疗")
            .font(YeyuTypography.caption)
            .foregroundStyle(YeyuColor.textCompliance)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: 逻辑

    private func loadChips() async {
        chipsLoading = true
        let labels = await ChipService.generateLabels(username: username)
        chipLabels = labels
        chipsLoading = false
    }

    private func startChat(with text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputFocused = false
        if CrisisGuard.shouldShowCrisisUI(for: trimmed) {
            appState.showCrisisSheet = true
        }
        appState.openChat(initialMessage: trimmed)
        input = ""
    }
}

/// 语音波形（4 根胶囊，对齐 411:2013 SVG 形态）。首页与对话页输入框共用。
struct VoiceWaveform: View {
    let color: Color
    private let heights: [CGFloat] = [4, 12, 7, 4]

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(heights.indices, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: 1.5, height: heights[i])
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(AppState())
}
