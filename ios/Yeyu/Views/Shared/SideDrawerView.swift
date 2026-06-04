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
        if appState.drawerOpen {
            ZStack(alignment: .leading) {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { appState.drawerOpen = false }

                drawerPanel
                    .transition(.move(edge: .leading))
            }
            .animation(.easeOut(duration: 0.25), value: appState.drawerOpen)
        }
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
            navRow(icon: "heart", label: "行动卡片") {
                appState.drawerOpen = false
                appState.openHistory()
            }
            navRow(icon: "square.and.pencil", label: "个性化") {
                appState.drawerOpen = false
                appState.openPersonalization()
            }
            navRow(icon: "tag", label: "支持鼓励") {
                // 占位：功能未排期，给一个克制的「敬请期待」提示，不关抽屉。
                showSupportToast = true
            }
            navRow(icon: "gearshape", label: "设置") {
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

    /// 面板材质：iOS 26 用暗色 Liquid Glass（与首页输入框统一语言），更低版本回退到暗底 + ultraThinMaterial。
    @ViewBuilder
    private var panelSurface: some View {
        if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(
                    .regular.tint(YeyuColor.backgroundDrawer.opacity(0.5)),
                    in: Rectangle()
                )
        } else {
            YeyuColor.backgroundDrawer.opacity(0.92)
                .background(.ultraThinMaterial)
        }
    }

    // MARK: 会员 Banner（226:2407）

    private var membershipBanner: some View {
        Button {
            // TODO: 接入二级「会员转化」弹窗（YUQI 后补）；当前占位提示。
            showSupportToast = true
        } label: {
            ZStack(alignment: .leading) {
                bannerArt
                Text("成为会员")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.leading, 172)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 72)
            .background(Color(hex: 0x282828))
            .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("成为会员")
    }

    /// 月 + 双山插画（原生绘制，对齐 226:2407 的月/山母题；暗海层近黑省略）。
    private var bannerArt: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0xEDEDED), Color(hex: 0x6B6B6B)],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 80, height: 80)
                .offset(x: 0, y: 17)
            BannerTriangle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0x8E8E8E), Color(hex: 0x3A3A3A)],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 98, height: 50)
                .offset(x: -10, y: 24)
                .opacity(0.85)
            BannerTriangle()
                .fill(LinearGradient(
                    colors: [Color(hex: 0x7C7C7C), Color(hex: 0x343434)],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 52, height: 30)
                .offset(x: 36, y: 33)
                .opacity(0.85)
        }
        .frame(width: 150, height: 72)
        .clipped()
    }

    private func navRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: YeyuSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .frame(width: 20)
                Text(label)
                    .font(YeyuTypography.callout)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.3))
            }
            .padding(.vertical, YeyuSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// 等腰三角（顶点居中朝上）— 会员 Banner 的「山」。
private struct BannerTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

#Preview {
    SideDrawerView()
        .environment(AppState())
}
