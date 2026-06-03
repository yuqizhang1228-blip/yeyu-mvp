import Foundation

/// 与 H5 `yeyu_username` 对齐（跳过存「你」视为匿名）
enum YeyuUser {
    static let usernameKey = "yeyu_username"
    static let uidKey = "yeyu_uid"
    static let anonymousPlaceholder = "你"

    static func displayName(stored: String) -> String? {
        let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed == anonymousPlaceholder { return nil }
        return trimmed
    }

    static func drawerLabel(stored: String) -> String {
        displayName(stored: stored) ?? "匿名用户"
    }

    static func needsNameSetup(stored: String) -> Bool {
        stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func systemNameLine(stored: String) -> String? {
        guard let name = displayName(stored: stored) else { return nil }
        return "【称呼】用户希望被称为\(name)。"
    }

    static func ensureUserId() -> String {
        if let existing = UserDefaults.standard.string(forKey: uidKey), !existing.isEmpty {
            return existing
        }
        let ts = Int(Date.now.timeIntervalSince1970)
        let uid = "YY-" + String(ts, radix: 36).uppercased()
            + String(UUID().uuidString.prefix(4)).uppercased()
        UserDefaults.standard.set(uid, forKey: uidKey)
        return uid
    }
}
