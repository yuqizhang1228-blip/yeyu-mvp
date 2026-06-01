import SwiftUI

@main
struct YeyuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 强制深色模式（夜屿为暗色专属体验）
                .preferredColorScheme(.dark)
        }
    }
}
