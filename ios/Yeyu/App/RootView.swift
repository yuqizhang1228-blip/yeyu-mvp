import SwiftUI

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .chat(let sessionId, let initialMessage):
                        ChatView(sessionId: sessionId, initialMessage: initialMessage)
                    case .history:
                        HistoryView()
                    }
                }
        }
        .environment(appState)
        // 设置页 — 以大弹窗呈现，不进导航栈
        .sheet(isPresented: Binding(
            get: { appState.showSettings },
            set: { appState.showSettings = $0 }
        )) {
            SettingsView()
        }
        // 个性化 — 可从抽屉直达，也可从设置内打开
        .sheet(isPresented: Binding(
            get: { appState.showPersonalization },
            set: { appState.showPersonalization = $0 }
        )) {
            PersonalizationView()
        }
    }
}

enum AppRoute: Hashable {
    case chat(sessionId: UUID, initialMessage: String?)
    case history
}

#Preview {
    RootView()
}
