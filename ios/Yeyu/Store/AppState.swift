import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@Observable
final class AppState {
    var navigationPath = NavigationPath()
    var drawerOpen = false
    var showCrisisSheet = false
    /// 设置页作为 sheet 呈现（不进导航栈）
    var showSettings = false
    /// 个性化页作为 sheet 呈现
    var showPersonalization = false

    /// 打开左侧抽屉，并给一次轻触觉反馈（YUQ-30：点击抽屉 icon 同时振动）。
    func openDrawer() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        drawerOpen = true
    }

    func openChat(sessionId: UUID = UUID(), initialMessage: String? = nil) {
        navigationPath.append(AppRoute.chat(sessionId: sessionId, initialMessage: initialMessage))
    }

    func openHistory() {
        navigationPath.append(AppRoute.history)
    }

    func openSettings() {
        showSettings = true
    }

    func openPersonalization() {
        showPersonalization = true
    }

    /// 对话顶栏「+」：归档当前会话后回到首页（HomeView 即新对话入口）
    func goHome() {
        navigationPath = NavigationPath()
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
