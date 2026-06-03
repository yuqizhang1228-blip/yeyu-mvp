import SwiftUI
import SwiftData

/// 左侧抽屉 — 功能范围见 `ios/DRAWER_SCOPE.md`（勿按 YUQ-30 全量 spec 扩入口）。
/// 设计稿：Figma `226:2399`（0515 · 左侧弹窗，v1 功能子集）
struct SideDrawerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @Query(sort: \ChatSession.updatedAt, order: .reverse) private var sessions: [ChatSession]

    var currentSessionId: UUID?

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

            // ── 品牌标题 ──────────────────────────────────────
            VStack(alignment: .leading, spacing: YeyuSpacing.xs) {
                Text("夜屿")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(.white)
                Text("一款情绪拆解 AI 助手")
                    .font(YeyuTypography.footnote)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            .padding(.bottom, YeyuSpacing.xxl)

            // ── 功能入口 ─────────────────────────────────────
            navRow(icon: "heart.text.square", label: "行动卡片") {
                appState.drawerOpen = false
                appState.openHistory()
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
                                            : .white
                                    )
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.vertical, YeyuSpacing.md)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.top, YeyuSpacing.xxxl)
        .padding(.bottom, YeyuSpacing.xl)
        .frame(width: 320)
        .frame(maxHeight: .infinity)
        .background {
            ZStack {
                Color(hex: 0x1A1A1A, alpha: 0.92)
            }
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
        }
        .overlay(alignment: .trailing) {
            // 右侧内边缘分割线（Figma: inset -1px 0px rgba(255,255,255,0.05)）
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1)
        }
    }

    private func navRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: YeyuSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .frame(width: 20)
                Text(label)
                    .font(YeyuTypography.body)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.3))
            }
            .padding(.vertical, YeyuSpacing.md)
        }
    }
}

#Preview {
    SideDrawerView()
        .environment(AppState())
}
