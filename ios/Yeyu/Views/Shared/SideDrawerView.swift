import SwiftUI
import SwiftData

/// 左侧抽屉 — 功能范围见 `ios/DRAWER_SCOPE.md`（勿按 YUQ-30 全量 spec 扩入口：
/// 无会员 Banner、无「支持鼓励」路由）。视觉对齐 Figma `226:2399`（0515 · 左侧弹窗）。
struct SideDrawerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @Query(sort: \ChatSession.updatedAt, order: .reverse) private var sessions: [ChatSession]

    var currentSessionId: UUID?

    /// 「支持鼓励」暂无 PRD/路由，先以占位提示呈现（YUQI 2026-06-03 裁决）。
    @State private var showSupportToast = false

    var body: some View {
        // 动画驱动放在「常驻」的 ZStack 上：之前把 .animation 放在 if 内，
        // 关闭时整块（含 .animation）被移除 → 收起瞬移、没有体感。常驻后开/合都走过渡。
        ZStack(alignment: .leading) {
            if appState.drawerOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { appState.drawerOpen = false }

                drawerPanel
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.88), value: appState.drawerOpen)
    }

    private var drawerPanel: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── 页眉：标题 + 关闭（411 同款菜单 icon）─────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: YeyuSpacing.xs) {
                    Text("夜屿")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(.white)
                    Text("一款情绪拆解 AI 助手")
                        .font(YeyuTypography.footnote)
                        .foregroundStyle(Color.white.opacity(0.7))
                }
                Spacer()
                Button { appState.drawerOpen = false } label: {
                    YeyuNavMenuIcon(tint: .white)
                        .frame(width: 44, height: 44, alignment: .topTrailing)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("收起菜单")
                .padding(.trailing, -((44 - 20) / 2))
                .offset(y: -10)
            }
            .padding(.bottom, YeyuSpacing.xl)

            // ── 会员转化 Banner（226:2407）────────────────────
            membershipBanner
                .padding(.bottom, YeyuSpacing.xxl)

            // ── 功能入口（行动卡片 / 个性化 / 支持鼓励 / 设置）──────
            navRow(icon: .heart, label: "行动卡片") {
                appState.drawerOpen = false
                appState.openHistory()
            }
            navRow(icon: .pencil, label: "个性化") {
                appState.drawerOpen = false
                appState.openPersonalization()
            }
            navRow(icon: .tag, label: "支持鼓励") {
                // 占位：功能未排期，给一个克制的「敬请期待」提示，不关抽屉。
                showSupportToast = true
            }
            navRow(icon: .gear, label: "设置") {
                appState.drawerOpen = false
                appState.openSettings()
            }

            // ── 最近对话 ─────────────────────────────────────
            Text("最近对话")
                .font(YeyuTypography.footnote)
                .foregroundStyle(Color.white.opacity(0.4))
                .padding(.top, YeyuSpacing.xxl)
                .padding(.bottom, YeyuSpacing.sm)

            ScrollView {
                VStack(spacing: 0) {
                    if sessions.isEmpty {
                        Text("还没有对话\n回到首页，说点什么开始吧")
                            .font(YeyuTypography.footnote)
                            .foregroundStyle(Color.white.opacity(0.3))
                            .lineSpacing(4)
                            .padding(.vertical, YeyuSpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ForEach(sessions.prefix(12)) { session in
                        Button {
                            appState.drawerOpen = false
                            if session.id == currentSessionId { return }
                            if currentSessionId != nil {
                                appState.replaceChat(sessionId: session.id, initialMessage: nil)
                            } else {
                                appState.openChat(sessionId: session.id, initialMessage: nil)
                            }
                        } label: {
                            HStack {
                                Text(session.title)
                                    .font(.system(size: 16))
                                    .foregroundStyle(
                                        session.id == currentSessionId
                                            ? YeyuColor.primary
                                            : Color.white.opacity(0.85)
                                    )
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.vertical, YeyuSpacing.md)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.top, YeyuSpacing.md)
        .padding(.bottom, YeyuSpacing.xl)
        .frame(width: 320)
        .frame(maxHeight: .infinity)
        // 材质满铺全屏高（含状态栏 / Home Indicator），内容仍守安全区。
        .background { panelSurface.ignoresSafeArea() }
        .overlay(alignment: .trailing) {
            // 右侧内边缘分割线（Figma: inset -1px 0px rgba(255,255,255,0.05)）
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1)
                .ignoresSafeArea()
        }
        .overlay(alignment: .bottom) {
            if showSupportToast { supportToast }
        }
        .animation(.easeInOut(duration: 0.2), value: showSupportToast)
        .sensoryFeedback(.impact(weight: .light), trigger: showSupportToast)
        .environment(\.colorScheme, .dark)
    }

    private var supportToast: some View {
        Text("敬请期待")
            .font(YeyuTypography.footnote)
            .foregroundStyle(.white)
            .padding(.horizontal, YeyuSpacing.lg)
            .padding(.vertical, YeyuSpacing.sm + 2)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 48)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .task(id: showSupportToast) {
                guard showSupportToast else { return }
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                showSupportToast = false
            }
            .accessibilityAddTraits(.isStaticText)
    }

    /// 面板材质：暗色磨砂底，**上下通栏、无玻璃描边圈**（仅靠 trailing 1px 右描边分隔）。
    /// 注：不用 `.glassEffect` —— Liquid Glass 会沿形状画一圈高光描边，与设计「只在右侧有描边」冲突。
    private var panelSurface: some View {
        YeyuColor.backgroundDrawer.opacity(0.92)
            .background(.ultraThinMaterial)
    }

    // MARK: 会员 Banner（226:2407）

    private var membershipBanner: some View {
        Button {
            // TODO: 接入二级「会员转化」弹窗（YUQI 后补）；当前占位提示。
            showSupportToast = true
        } label: {
            // 切图（含「成为会员」文案）：等比铺满内容宽，圆角裁切
            Image("MembershipBanner")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("成为会员")
    }

    private func navRow(icon: YeyuVectorIcon, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: YeyuSpacing.md) {
                YeyuVectorIconView(icon: icon, size: 20, lineWidth: 1.5, tint: .white)
                Text(label)
                    .font(YeyuTypography.callout)
                    .foregroundStyle(.white)
                Spacer()
                YeyuVectorIconView(icon: .chevron, size: 16, lineWidth: 1.5, tint: Color.white.opacity(0.3))
            }
            .padding(.vertical, YeyuSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SideDrawerView()
        .environment(AppState())
}
