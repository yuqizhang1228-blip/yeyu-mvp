import SwiftUI
import SwiftData

@main
struct YeyuApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            return try SwiftDataBootstrap.makeContainer()
        } catch {
            fatalError("SwiftData 初始化失败: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
