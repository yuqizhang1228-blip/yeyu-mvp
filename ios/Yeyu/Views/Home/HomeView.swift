import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @State private var input = ""
    @State private var chipLabels: [String] = []
    @State private var chipsLoading = true

    private var needsNameSetup: Bool {
        YeyuUser.needsNameSetup(stored: username)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            YeyuColor.backgroundBase.ignoresSafeArea()

            if needsNameSetup {
                ScrollView {
                    NameSetupView(username: $username)
                        .padding(.horizontal, YeyuSpacing.xl)
                        .padding(.top, YeyuSpacing.xxxl)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: YeyuSpacing.xxl) {
                        header
                        greeting
                        chipSection
                        inputSection
                    }
                    .padding(.horizontal, YeyuSpacing.xl)
                    .padding(.bottom, YeyuSpacing.xxxl)
                }
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

    private var header: some View {
        HStack {
            Button {
                appState.drawerOpen = true
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Rectangle().frame(width: 20, height: 1.5)
                    Rectangle().frame(width: 14, height: 1.5)
                    Rectangle().frame(width: 20, height: 1.5)
                }
                .foregroundStyle(YeyuColor.textPrimary)
            }
            .accessibilityLabel("打开菜单")
            Spacer()
        }
        .padding(.top, YeyuSpacing.sm)
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
            // 两行问候，对齐 Figma 411:1996 · 26pt regular
            VStack(alignment: .leading, spacing: 2) {
                Text(timeGreeting + "，")
                    .font(YeyuTypography.displayGreeting)
                    .foregroundStyle(YeyuColor.textTitle)
                if let name = YeyuUser.displayName(stored: username) {
                    Text("\(name)，今晚想聊点什么？")
                        .font(YeyuTypography.displayGreeting)
                        .foregroundStyle(YeyuColor.textTitle)
                } else {
                    Text("欢迎来到夜屿。")
                        .font(YeyuTypography.displayGreeting)
                        .foregroundStyle(YeyuColor.textTitle)
                }
            }
            Text("在这里分享你的困惑，我来帮你梳理思绪。")
                .font(YeyuTypography.footnote)
                .foregroundStyle(Color.white.opacity(0.8))
        }
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

    @ViewBuilder
    private var chipSection: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.md) {
            if chipsLoading {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                        .fill(YeyuColor.surfacePromptCard)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                                .stroke(YeyuColor.borderPromptCard, lineWidth: 1)
                        )
                        .redacted(reason: .placeholder)
                }
            } else {
                ForEach(chipLabels, id: \.self) { text in
                    Button {
                        startChat(with: text)
                    } label: {
                        Text(text)
                            .font(YeyuTypography.body)
                            .foregroundStyle(YeyuColor.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(YeyuSpacing.lg)
                            .background(YeyuColor.surfacePromptCard)
                            .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.promptCard))
                            .overlay(
                                RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                                    .stroke(YeyuColor.borderPromptCard, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var inputSection: some View {
        HStack(spacing: YeyuSpacing.sm) {
            TextField("随便聊聊...", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .font(YeyuTypography.body)
                .foregroundStyle(YeyuColor.textSecondary)
                .padding(.horizontal, YeyuSpacing.lg)
                .padding(.vertical, YeyuSpacing.md)
                .background(YeyuColor.backgroundInput)
                .clipShape(Capsule())

            Button {
                startChat(with: input)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(YeyuColor.textInverse)
                    .frame(width: 39, height: 39)
                    .background(YeyuColor.primary)
                    .clipShape(Circle())
            }
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        }
    }

    private func loadChips() async {
        chipsLoading = true
        let labels = await ChipService.generateLabels(username: username)
        chipLabels = labels
        chipsLoading = false
    }

    private func startChat(with text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
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
