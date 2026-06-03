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
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .environment(appState)
    }
}

enum AppRoute: Hashable {
    case chat(sessionId: UUID, initialMessage: String?)
    case history
    case settings
}

#Preview {
    RootView()
}
