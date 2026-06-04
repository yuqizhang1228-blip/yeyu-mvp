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
        // 长期记忆条目（YUQ-39）：对话沉淀 + 用户自定义
        let mems = MemoryStore.all()
        if !mems.isEmpty {
            let list = mems.prefix(8).map { "・\($0.text)" }.joined(separator: "\n")
            lines.append("关于 TA 的长期记忆（判断场景方向用，勿原样复述）：\n\(list)")
        }
        guard !lines.isEmpty else { return nil }
        return "【本地记忆摘要——仅用于你选「更可能点中 TA」的场景方向，勿在输出 JSON 里暴露备注原文】\n" + lines.joined(separator: "\n")
    }
}

// MARK: - 长期记忆（YUQ-39）

/// 单条记忆：对话沉淀（auto）或用户手动添加（manual）。
struct MemoryEntry: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var text: String
    var createdAt: Date = .now
    var source: String = "auto"   // "auto" | "manual"
}

/// 本地记忆库（独立 UserDefaults 键，避免改 `UserProfile` 触发解码迁移）。
enum MemoryStore {
    private static let key = "yeyu_memories"
    private static let maxCount = 50

    static var autoEnabled: Bool {
        // 与 PersonalizationView 的「参考保存记忆」开关同键；默认开。
        UserDefaults.standard.object(forKey: "yeyu_auto_memory") as? Bool ?? true
    }

    static func all() -> [MemoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([MemoryEntry].self, from: data) else { return [] }
        return items
    }

    private static func persist(_ items: [MemoryEntry]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    @discardableResult
    static func add(_ text: String, source: String = "auto") -> Bool {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count >= 4 else { return false }
        var items = all()
        let norm = normalize(t)
        guard !items.contains(where: { normalize($0.text) == norm }) else { return false }
        items.insert(MemoryEntry(text: t, source: source), at: 0)
        persist(Array(items.prefix(maxCount)))
        return true
    }

    static func delete(_ id: UUID) {
        persist(all().filter { $0.id != id })
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// 注入主对话 system 的记忆补充（控量 top-8）；无记忆返回 nil。
    static func chatSystemLine() -> String? {
        let mems = all()
        guard !mems.isEmpty else { return nil }
        let list = mems.prefix(8).map { "・\($0.text)" }.joined(separator: "\n")
        return "【关于对方的长期记忆——自然融入即可，别主动复述、别让对方觉得被监视；与当前话题无关就忽略】\n\(list)"
    }

    // MARK: 抽取节流（按会话去重，避免重复/频繁调用）

    private static let extractedKey = "yeyu_mem_extracted_sessions"

    static func hasExtracted(_ sessionId: UUID) -> Bool {
        extractedSet().contains(sessionId.uuidString)
    }

    static func markExtracted(_ sessionId: UUID) {
        var set = extractedSet()
        set.insert(sessionId.uuidString)
        var arr = Array(set)
        if arr.count > 200 { arr = Array(arr.suffix(200)) }
        UserDefaults.standard.set(arr, forKey: extractedKey)
    }

    private static func extractedSet() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: extractedKey) ?? [])
    }

    /// 精确归一化去重（去空格/句号、小写）。语义级去重见难度评估，暂不做。
    private static func normalize(_ s: String) -> String {
        s.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "。", with: "")
            .replacingOccurrences(of: "，", with: "")
            .lowercased()
    }
}

/// 对话 → 记忆抽取（YUQ-39 闭环的「沉淀」环节）。
/// 在一段对话收束时调用；仅在「参考保存记忆」开启时写入。
enum MemoryExtractionService {
    /// 抽取提示词走正规流程：`prompts/memory_extraction.md` → bundle；缺失时回退内联。
    private static var systemPrompt: String {
        let loaded = PromptLoader.load("memory_extraction")
        return loaded.isEmpty ? inlineFallback : loaded
    }

    private static let inlineFallback = """
    你是一个「用户长期记忆」抽取器。下面是用户与一个情绪陪伴 AI 的一段对话。
    请只抽取关于「用户本人」长期稳定、值得长期记住的事实或处境，例如：职业/身份、长期目标、反复出现的核心困扰、重要关系、明确的价值观或偏好。
    严格要求：
    - 不要抽取一次性的情绪、寒暄、客套，或只在本次对话里成立的临时状态。
    - 每条一句话，用第三人称「用户……」，尽量简洁具体。
    - 如果没有值得长期记住的，返回空数组 []。
    - 只输出 JSON 字符串数组本身，例如 ["用户是一名UX设计师","用户正在思考职业方向"]，禁止任何解释或额外文字。
    """

    /// 按会话节流：同一会话只抽一次（在网络调用前标记，避免归档+退后台双触发重复扣费）。
    static func extractAndStore(sessionId: UUID, fromTranscript transcript: String) async {
        guard MemoryStore.autoEnabled, !MemoryStore.hasExtracted(sessionId) else { return }
        let convo = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard convo.count >= 60 else { return }
        MemoryStore.markExtracted(sessionId)
        let client = ChatAPIClient()
        do {
            let raw = try await client.send(
                messages: [.init(role: "user", content: String(convo.prefix(4000)))],
                systemPrompt: systemPrompt,
                extraSystemMessages: [],
                maxTokens: 300
            )
            guard let items = parseJSONArray(raw) else { return }
            for item in items.prefix(5) {
                _ = MemoryStore.add(item, source: "auto")
            }
        } catch {
            // 抽取失败静默忽略，不打断主流程
        }
    }

    private static func parseJSONArray(_ raw: String) -> [String]? {
        // 容错：截取首个 [ ... ]
        guard let start = raw.firstIndex(of: "["),
              let end = raw.lastIndex(of: "]"), start < end else { return nil }
        let slice = String(raw[start...end])
        guard let data = slice.data(using: .utf8),
              let arr = try? JSONDecoder().decode([String].self, from: data) else { return nil }
        return arr
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
