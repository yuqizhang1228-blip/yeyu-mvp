import Foundation

enum ChipService {
    private static let count = 5
    private static let maxChars = 40

    static let fallbackLabels = [
        "会上被当众否了，话很难听，脸上发烧想躲。",
        "绩效又被压一档，说不清哪里不对，开始怀疑自己。",
        "被项目架空了，说话没人接，不知道自己还重不重要。",
        "消息显示已读却迟迟没回，忍不住一遍遍看手机。",
        "和父母通完电话，心里又堵又空，说不清谁对谁错。",
    ]

    static func generateLabels(username: String = "") async -> [String] {
        let ctx = TimeContext.current()
        let system = PromptLoader.load("chip_system", replacements: chipReplacements(for: ctx))
        var extra: [String] = []
        if let mem = UserProfileService.chipMemorySummary(username: username) {
            extra.append(mem)
        }

        let client = ChatAPIClient()
        do {
            let raw = try await client.send(
                messages: [
                    .init(role: "user", content: "生成5个\(ctx.period)可能遇到的情绪场景。尽量贴近摘要里的真实纹理；没有摘要则写通用场景。"),
                ],
                systemPrompt: system.isEmpty ? inlineChipFallback(ctx) : system,
                extraSystemMessages: extra,
                maxTokens: 320
            )
            if let labels = parseJSONArray(raw), labels.count >= count {
                return labels.prefix(count).map(finalize).filter { !$0.isEmpty }
            }
        } catch {
            // fallback below
        }
        return fallbackLabels
    }

    private static func chipReplacements(for ctx: TimeContext) -> [String: String] {
        let timeHint: String
        switch ctx.period {
        case "清晨": timeHint = "这个时段通常是：刚醒，可能带着昨晚的情绪，或担心今天。"
        case "上午": timeHint = "这个时段通常是：工作中，刚经历职场冲突，或被消息刺痛。"
        case "午后": timeHint = "这个时段通常是：午休后，可能刚开完会、被否、或绩效谈话。"
        case "傍晚": timeHint = "这个时段通常是：快下班，疲惫感，或担心今晚/明天。"
        case "夜晚": timeHint = "这个时段通常是：晚饭后，独处时间，开始复盘今天。"
        default: timeHint = "这个时段通常是：翻来覆去，脑子里停不下来。"
        }
        let nightHint = ctx.period == "深夜"
            ? "可以稍微更私密、更难释怀一些，因为深夜人更脆弱"
            : "贴合当前时段的真实困扰"
        return [
            "period": ctx.period,
            "time_hint": timeHint,
            "period_night_hint": nightHint,
        ]
    }

    private static func inlineChipFallback(_ ctx: TimeContext) -> String {
        let r = chipReplacements(for: ctx)
        return """
        你是夜屿的Chip生成助手。现在用户打开应用的时间是「\(r["period"] ?? "")」。\(r["time_hint"] ?? "")
        生成5个让用户一看就"被点到"的情绪场景。只输出JSON数组，恰好5个字符串。
        """
    }

    private static func parseJSONArray(_ text: String) -> [String]? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let start = trimmed.firstIndex(of: "["),
              let end = trimmed.lastIndex(of: "]") else { return nil }
        let slice = String(trimmed[start...end])
        guard let data = slice.data(using: .utf8),
              let arr = try? JSONDecoder().decode([String].self, from: data) else { return nil }
        return arr
    }

    private static func finalize(_ raw: String) -> String {
        var t = raw.replacingOccurrences(of: "\n", with: " ")
        while t.contains("  ") { t = t.replacingOccurrences(of: "  ", with: " ") }
        t = t.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count <= maxChars { return t }
        return String(t.prefix(maxChars - 1)) + "…"
    }
}
