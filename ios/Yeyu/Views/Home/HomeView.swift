import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 首页（YUQ-27 高保真 · Figma 0515 `page/home` 411:1996）
/// 结构：背景插画 + 渐变 → 顶栏 → 两行问候 → 横向快捷话题 → 玻璃输入框 → 合规一行。
struct HomeView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @State private var input = ""
    @State private var chipLabels: [String]
    @State private var chipsLoading: Bool
    @FocusState private var inputFocused: Bool

    init() {
        // 用缓存初始化：命中则首屏直接显示、无骨架闪烁、不触发刷新
        let cached = ChipCache.validLabels(for: TimeContext.current().period)
        _chipLabels = State(initialValue: cached ?? [])
        _chipsLoading = State(initialValue: cached == nil)
    }

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
                YeyuNavMenuIcon()
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

    // MARK: 玻璃输入框（411:2006 · 与 `414:2187` 同组件）

    private var inputBox: some View {
        YeyuInputBox(
            text: $input,
            placeholder: "随便聊聊...",
            focus: $inputFocused,
            submitLabel: .send,
            onSubmit: { startChat(with: input) },
            onSend: { startChat(with: input) },
            onVoiceTapWhenEmpty: { inputFocused = true }
        )
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
        let period = TimeContext.current().period
        // 命中缓存（同时段、当天）→ 秒显、不刷新、不调用 API
        if let cached = ChipCache.validLabels(for: period) {
            chipLabels = cached
            chipsLoading = false
            return
        }
        chipsLoading = true
        let labels = await ChipService.generateLabels(username: username)
        chipLabels = labels
        chipsLoading = false
        ChipCache.save(labels: labels, period: period)
    }

    private func startChat(with text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputFocused = false
        // 发送瞬间触觉反馈（与对话页一致）
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        if CrisisGuard.shouldShowCrisisUI(for: trimmed) {
            appState.showCrisisSheet = true
        }
        appState.openChat(initialMessage: trimmed)
        input = ""
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(AppState())
}
