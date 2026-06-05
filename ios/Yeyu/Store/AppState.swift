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

    // MARK: 记忆 toast（顶部「已加入记忆」气泡，全局呈现）
    /// 当前展示的记忆 toast；nil 表示不展示。
    var memoryToast: MemoryToast?
    private var toastQueue: [MemoryToast] = []
    private var toastPlaying = false

    struct MemoryToast: Identifiable, Equatable {
        let id = UUID()
        let text: String
        let kind: MemoryChange.Kind
    }

    /// 调和产生变更后调用：把变更转成一条 toast 入队、依次播放。
    @MainActor
    func showMemoryToast(_ changes: [MemoryChange]) {
        guard let toast = Self.makeToast(changes) else { return }
        toastQueue.append(toast)
        if !toastPlaying { playNextToast() }
    }

    @MainActor
    private func playNextToast() {
        guard !toastQueue.isEmpty else { toastPlaying = false; return }
        toastPlaying = true
        let next = toastQueue.removeFirst()
        memoryToast = next
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            if memoryToast?.id == next.id { memoryToast = nil }
            try? await Task.sleep(nanoseconds: 280_000_000) // 退场动画间隙
            playNextToast()
        }
    }

    static func makeToast(_ changes: [MemoryChange]) -> MemoryToast? {
        guard !changes.isEmpty else { return nil }
        if changes.count == 1, let c = changes.first {
            let s = displaySnippet(c.entry.text)
            let text = c.kind == .added ? "「\(s)」已加入记忆" : "已更新记忆：「\(s)」"
            return MemoryToast(text: text, kind: c.kind)
        }
        return MemoryToast(text: "已为你记住 \(changes.count) 件事", kind: .added)
    }

    /// toast 展示用：去掉「用户」前缀、收尾标点、截断。
    static func displaySnippet(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        for p in ["用户们", "用户", "TA", "ta"] where s.hasPrefix(p) {
            s.removeFirst(p.count); break
        }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "：:，, 　、"))
        if s.count > 18 { s = String(s.prefix(18)) + "…" }
        return s.isEmpty ? raw : s
    }

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
