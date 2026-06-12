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
    /// 事实更新/合并或手动编辑时间（「已更新」语义 + 排序）；首次创建为 nil。
    var updatedAt: Date? = nil
}

/// 一次调和产生的变更（供顶部 toast）。
struct MemoryChange: Equatable {
    enum Kind { case added, updated }
    let kind: Kind
    let entry: MemoryEntry
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

    /// 新增一条；精确重复或过短返回 nil（兜底去重，语义去重由调和 LLM 负责）。
    @discardableResult
    static func add(_ text: String, source: String = "auto") -> MemoryEntry? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count >= 4 else { return nil }
        var items = all()
        let norm = normalize(t)
        guard !items.contains(where: { normalize($0.text) == norm }) else { return nil }
        let entry = MemoryEntry(text: t, source: source)
        items.insert(entry, at: 0)
        persist(Array(items.prefix(maxCount)))
        return entry
    }

    /// 更新某条文本（事实更新/合并 或 手动编辑）。返回更新后的 entry；id 不存在返回 nil。
    @discardableResult
    static func update(id: UUID, text: String) -> MemoryEntry? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count >= 4 else { return nil }
        var items = all()
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return nil }
        items[idx].text = t
        items[idx].updatedAt = .now
        persist(items)
        return items[idx]
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

    // MARK: 调和节流游标（按会话记录「已处理到的消息数」，每轮只发增量）

    private static let cursorKey = "yeyu_mem_cursor"

    struct ReconcileCursor: Codable {
        var processedCount: Int = 0
        var lastAt: Date? = nil
    }

    static func cursor(_ sessionId: UUID) -> ReconcileCursor {
        guard let data = UserDefaults.standard.data(forKey: cursorKey),
              let map = try? JSONDecoder().decode([String: ReconcileCursor].self, from: data),
              let c = map[sessionId.uuidString] else { return ReconcileCursor() }
        return c
    }

    static func setCursor(_ sessionId: UUID, _ cursor: ReconcileCursor) {
        var map: [String: ReconcileCursor] = {
            guard let data = UserDefaults.standard.data(forKey: cursorKey),
                  let m = try? JSONDecoder().decode([String: ReconcileCursor].self, from: data) else { return [:] }
            return m
        }()
        map[sessionId.uuidString] = cursor
        // 控量：最多保留 200 个会话游标
        if map.count > 200 {
            let keep = map.sorted { ($0.value.lastAt ?? .distantPast) > ($1.value.lastAt ?? .distantPast) }.prefix(200)
            map = Dictionary(uniqueKeysWithValues: keep.map { ($0.key, $0.value) })
        }
        if let data = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(data, forKey: cursorKey)
        }
    }

    /// 精确归一化去重（去空格/句号、小写）。语义级去重见难度评估，暂不做。
    private static func normalize(_ s: String) -> String {
        s.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "。", with: "")
            .replacingOccurrences(of: "，", with: "")
            .lowercased()
    }
}

/// 对话 → 记忆「调和」（YUQ-37/39 闭环的「沉淀」环节）。
/// 每轮 AI 回复后（节流）调用：把「现有记忆 + 增量对话」交给 LLM，
/// 返回结构化 {add, update} —— 一次完成语义去重 + 事实更新/合并。
/// 仅在「参考保存记忆」开启时写入。
enum MemoryReconcileService {
    /// 单次最少新增对话字数（低于则跳过，控成本）
    private static let minNewChars = 40
    /// 发给模型的现有记忆上限 / 增量对话上限
    private static let maxExistingForPrompt = 30
    private static let maxDialogueChars = 3000

    /// 防止同会话并发调和（避免重复写入）
    @MainActor private static var inFlight: Set<UUID> = []

    private static var systemPrompt: String {
        let loaded = PromptLoader.load("memory_extraction")
        return loaded.isEmpty ? inlineFallback : loaded
    }

    private static let inlineFallback = """
    你是一个「用户长期记忆」调和器。给你 A=该用户已有的长期记忆（带编号），B=最近一段用户与情绪陪伴 AI 的对话。
    只关注关于「用户本人」长期稳定、值得长期记住的事实或处境（职业/身份、长期目标、反复出现的核心困扰、重要关系、明确价值观或偏好）。
    请输出对记忆库的「操作」：
    - add：B 中出现、A 里没有（语义上也没有）的新长期事实。
    - update：B 中的信息是对 A 中某条的更新/纠正（如换了工作、目标变化），给出该条编号与新文本。
    严格要求：
    - 不要 add 与 A 语义重复的内容（即使措辞不同）。这是去重的关键。
    - 不要抽取一次性情绪、寒暄、客套或仅本次成立的临时状态。
    - 每条一句话，第三人称「用户……」，简洁具体。
    - 没有任何操作就返回 {"add":[],"update":[]}。
    - 只输出 JSON 对象本身，例如 {"add":["用户在准备考研"],"update":[{"index":2,"text":"用户现在在一家创业公司做设计"}]}，禁止任何解释或额外文字。
    """

    /// 调和并写入。`messages` 为该会话按时序的 (role, content)（role: "user"/"assistant"）。
    /// 返回本次产生的变更（供顶部 toast）。`force=true` 跳过「最少字数」节流（用于会话结束兜底）。
    @discardableResult
    static func reconcile(
        sessionId: UUID,
        messages: [(role: String, content: String)],
        force: Bool = false
    ) async -> [MemoryChange] {
        guard MemoryStore.autoEnabled else { return [] }

        // 并发守卫
        let proceed = await MainActor.run { () -> Bool in
            if inFlight.contains(sessionId) { return false }
            inFlight.insert(sessionId)
            return true
        }
        guard proceed else { return [] }
        defer { Task { @MainActor in inFlight.remove(sessionId) } }

        // 增量切片
        var cursor = MemoryStore.cursor(sessionId)
        let start = min(cursor.processedCount, messages.count)
        let newSlice = Array(messages[start...])
        guard !newSlice.isEmpty else { return [] }
        let newText = newSlice.map { $0.content }.joined()
        guard force || newText.count >= minNewChars else { return [] }

        let existing = Array(MemoryStore.all().prefix(maxExistingForPrompt))
        let userPrompt = buildPrompt(existing: existing, dialogue: newSlice)

        let client = ChatAPIClient()
        let raw: String
        do {
            raw = try await client.send(
                messages: [.init(role: "user", content: userPrompt)],
                systemPrompt: systemPrompt,
                extraSystemMessages: [],
                maxTokens: 320
            )
        } catch {
            return [] // 失败静默；不推进游标，下轮重试
        }

        guard let ops = parseOps(raw) else {
            // 解析失败也推进游标，避免卡在同一片段反复请求
            cursor.processedCount = messages.count
            cursor.lastAt = .now
            MemoryStore.setCursor(sessionId, cursor)
            return []
        }

        var changes: [MemoryChange] = []
        for text in ops.add.prefix(5) {
            if let entry = MemoryStore.add(text, source: "auto") {
                changes.append(.init(kind: .added, entry: entry))
            }
        }
        for u in ops.update.prefix(5) {
            guard existing.indices.contains(u.index - 1) else { continue }
            let target = existing[u.index - 1]
            // 仅自动来源可被自动更新；手动条目不被改写
            guard target.source == "auto" else { continue }
            if let entry = MemoryStore.update(id: target.id, text: u.text) {
                changes.append(.init(kind: .updated, entry: entry))
            }
        }

        cursor.processedCount = messages.count
        cursor.lastAt = .now
        MemoryStore.setCursor(sessionId, cursor)
        return changes
    }

    private static func buildPrompt(existing: [MemoryEntry], dialogue: [(role: String, content: String)]) -> String {
        let memBlock: String
        if existing.isEmpty {
            memBlock = "（暂无）"
        } else {
            memBlock = existing.enumerated()
                .map { "\($0.offset + 1)) \($0.element.text)" }
                .joined(separator: "\n")
        }
        var convo = dialogue
            .map { ($0.role == "user" ? "用户" : "AI") + "：" + $0.content }
            .joined(separator: "\n")
        if convo.count > maxDialogueChars { convo = String(convo.suffix(maxDialogueChars)) }
        return "A=已有记忆：\n\(memBlock)\n\nB=最近对话：\n\(convo)"
    }

    private struct Ops {
        var add: [String]
        var update: [(index: Int, text: String)]
    }

    private static func parseOps(_ raw: String) -> Ops? {
        guard let start = raw.firstIndex(of: "{"),
              let end = raw.lastIndex(of: "}"), start < end else { return nil }
        let slice = String(raw[start...end])
        guard let data = slice.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        let add = (obj["add"] as? [Any])?.compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []
        var updates: [(index: Int, text: String)] = []
        if let arr = obj["update"] as? [[String: Any]] {
            for u in arr {
                let idx = (u["index"] as? Int) ?? Int("\(u["index"] ?? "")")
                let text = (u["text"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                if let idx, let text, !text.isEmpty { updates.append((idx, text)) }
            }
        }
        return Ops(add: add, update: updates)
    }
}
