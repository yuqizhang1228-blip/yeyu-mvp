import SwiftUI

@Observable
final class AppState {
    var navigationPath = NavigationPath()
    var drawerOpen = false
    var showCrisisSheet = false

    func openChat(sessionId: UUID = UUID(), initialMessage: String? = nil) {
        navigationPath.append(AppRoute.chat(sessionId: sessionId, initialMessage: initialMessage))
    }

    func openHistory() {
        navigationPath.append(AppRoute.history)
    }

    func openSettings() {
        navigationPath.append(AppRoute.settings)
    }

    /// 新建对话：替换当前 Chat 路由，避免栈里叠多层会话页
    func replaceChat(sessionId: UUID = UUID(), initialMessage: String? = nil) {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(AppRoute.chat(sessionId: sessionId, initialMessage: initialMessage))
    }

    /// 从行动卡片列表回到某场对话（重置导航栈为 Home → Chat）
    func openChatFromHistory(sessionId: UUID) {
        navigationPath = NavigationPath()
        navigationPath.append(AppRoute.chat(sessionId: sessionId, initialMessage: nil))
    }
}
