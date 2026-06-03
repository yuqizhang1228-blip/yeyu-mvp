import Foundation
import SwiftData

/// 创建 ModelContainer；schema 变更时用新 store 名，必要时清理损坏库（避免启动崩溃）。
enum SwiftDataBootstrap {
    /// 与 `choiceGuideCompleted` 等字段变更对齐， bump 后旧库不再加载。
    private static let storeName = "YeyuStore_v2"

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            ChatSession.self,
            ChatMessage.self,
            MemoryCard.self,
        ])
        let config = ModelConfiguration(storeName, schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            removeStoreFiles(named: storeName)
            return try ModelContainer(for: schema, configurations: [config])
        }
    }

    private static func removeStoreFiles(named name: String) {
        guard let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        let candidates = [
            "\(name).store", "\(name).store-shm", "\(name).store-wal",
            "default.store", "default.store-shm", "default.store-wal",
        ]
        for file in candidates {
            try? FileManager.default.removeItem(at: support.appendingPathComponent(file))
        }
    }
}
