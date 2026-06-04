import Foundation
import SwiftData

enum DataResetService {
    static func clearAll(modelContext: ModelContext) throws {
        try deleteAll(ChatSession.self, in: modelContext)
        try deleteAll(ChatMessage.self, in: modelContext)
        try deleteAll(MemoryCard.self, in: modelContext)
        try modelContext.save()

        let keys = [YeyuUser.usernameKey, YeyuUser.uidKey, "yeyu_auto_memory"]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserProfileService.clear()
        MemoryStore.clear()
        ChipCache.clear()
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, in context: ModelContext) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try context.fetch(descriptor)
        for item in items {
            context.delete(item)
        }
    }
}
