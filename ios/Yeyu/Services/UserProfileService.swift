import Foundation

/// 对齐 H5 `yeyu_profile`（Chip / 长期纹理，不含对话原文）
struct UserProfile: Codable {
    var visitCount: Int = 0
    var lastVisitAt: String?
    var preferredTimeSlots: [String] = []
    var commonThemes: [String] = []
    var recentCardTopics: [String] = []
    var manualNote: String = ""
}

enum UserProfileService {
    private static let storageKey = "yeyu_profile"

    static func load() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return UserProfile()
        }
        return profile
    }

    static func save(_ profile: UserProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    static func recordVisit() {
        var profile = load()
        profile.visitCount += 1
        profile.lastVisitAt = ISO8601DateFormatter().string(from: .now)
        let period = TimeContext.current().period
        if !profile.preferredTimeSlots.contains(period) {
            profile.preferredTimeSlots.append(period)
        }
        save(profile)
    }

    static func recordCardTopic(thought: String) {
        let topic = thought
            .replacingOccurrences(of: "「", with: "")
            .replacingOccurrences(of: "」", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !topic.isEmpty else { return }
        var profile = load()
        profile.recentCardTopics.removeAll { $0 == topic }
        profile.recentCardTopics.insert(topic, at: 0)
        profile.recentCardTopics = Array(profile.recentCardTopics.prefix(3))
        save(profile)
    }

    /// 供 Chip 生成用的 system 补充（对齐 H5 `getProfileSummaryForChips`）
    static func chipMemorySummary(username: String) -> String? {
        let profile = load()
        var lines: [String] = []
        if let name = YeyuUser.displayName(stored: username) {
            lines.append("对方常用称呼：\(name)（场景文案仍用第一人称「我」，不要写进这个名字）。")
        }
        if profile.visitCount > 1 {
            lines.append("累计使用约 \(profile.visitCount) 次，可理解为回访用户。")
        }
        if !profile.preferredTimeSlots.isEmpty {
            lines.append("常出现的来访时段：\(profile.preferredTimeSlots.prefix(4).joined(separator: "、"))。")
        }
        if !profile.recentCardTopics.isEmpty {
            let topics = profile.recentCardTopics.prefix(3).map { "「\($0)」" }.joined(separator: "、")
            lines.append("最近行动卡片常围绕的念头：\(topics)——可做同主题下的新切口，不要复述原句。")
        }
        let note = profile.manualNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty {
            lines.append("对方在设置里写下的备忘（摘录）：\(String(note.prefix(220)))")
        }
        guard !lines.isEmpty else { return nil }
        return "【本地记忆摘要——仅用于你选「更可能点中 TA」的场景方向，勿在输出 JSON 里暴露备注原文】\n" + lines.joined(separator: "\n")
    }
}
