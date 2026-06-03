import SwiftUI
import SwiftData

/// 左侧抽屉 — 功能范围见 `ios/DRAWER_SCOPE.md`（勿按 YUQ-30 全量 spec 扩入口）。
struct SideDrawerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @AppStorage(YeyuUser.usernameKey) private var username = ""
    @Query(sort: \ChatSession.updatedAt, order: .reverse) private var sessions: [ChatSession]

    var currentSessionId: UUID?

    var body: some View {
        if appState.drawerOpen {
            ZStack(alignment: .leading) {
                YeyuColor.overlay
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
            VStack(alignment: .leading, spacing: YeyuSpacing.xs) {
                Text("夜屿")
                    .font(YeyuTypography.title)
                    .foregroundStyle(YeyuColor.textTitle)
                Text(YeyuUser.drawerLabel(stored: username))
                    .font(YeyuTypography.footnote)
                    .foregroundStyle(YeyuColor.textTertiary)
            }
            .padding(.bottom, YeyuSpacing.xxl)

            navRow(icon: "rectangle.stack", label: "行动卡片") {
                appState.drawerOpen = false
                appState.openHistory()
            }
            navRow(icon: "gearshape", label: "设置") {
                appState.drawerOpen = false
                appState.openSettings()
            }

            Text("最近对话")
                .font(YeyuTypography.footnote)
                .foregroundStyle(YeyuColor.textTertiary)
                .padding(.top, YeyuSpacing.xxl)
                .padding(.bottom, YeyuSpacing.sm)

            ScrollView {
                VStack(spacing: YeyuSpacing.sm) {
                    ForEach(sessions.prefix(12)) { session in
                        Button {
                            appState.drawerOpen = false
                            if session.id == currentSessionId {
                                return
                            }
                            if currentSessionId != nil {
                                appState.replaceChat(sessionId: session.id, initialMessage: nil)
                            } else {
                                appState.openChat(sessionId: session.id, initialMessage: nil)
                            }
                        } label: {
                            HStack {
                                Text(session.title)
                                    .font(YeyuTypography.body)
                                    .foregroundStyle(
                                        session.id == currentSessionId
                                            ? YeyuColor.primary
                                            : YeyuColor.textSecondary
                                    )
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.vertical, YeyuSpacing.sm)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.top, YeyuSpacing.xxxl)
        .padding(.bottom, YeyuSpacing.xl)
        .frame(width: 304)
        .frame(maxHeight: .infinity)
        .background(YeyuColor.backgroundElevated)
    }

    private func navRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: YeyuSpacing.md) {
                Image(systemName: icon)
                    .foregroundStyle(YeyuColor.textSecondary)
                Text(label)
                    .font(YeyuTypography.callout)
                    .foregroundStyle(YeyuColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(YeyuColor.textTertiary)
            }
            .padding(.vertical, YeyuSpacing.md)
        }
    }
}

#Preview {
    SideDrawerView()
        .environment(AppState())
}
