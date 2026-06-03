import Foundation
import SwiftData

@Model
final class MemoryCard {
    @Attribute(.unique) var id: UUID
    var sessionId: UUID
    var title: String
    var thought: String
    var reframe: String
    var actions: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        sessionId: UUID,
        title: String,
        thought: String,
        reframe: String,
        actions: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.sessionId = sessionId
        self.title = title
        self.thought = thought
        self.reframe = reframe
        self.actions = actions
        self.createdAt = createdAt
    }

    var displayActions: [String] {
        if let data = actions.data(using: .utf8),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            return arr
        }
        return actions
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

/// 解析 H5 兼容的 `<card>` 块（YUQ-44 确认流在保存前调用）
struct ParsedActionCard: Identifiable {
    let id = UUID()
    let thought: String
    let reframe: String
    let actions: String

    var actionItems: [String] {
        if let data = actions.data(using: .utf8),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            return arr
        }
        return actions
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

private struct CardJSONPayload: Decodable {
    let thought: String
    let reframe: String
    let actions: [String]?
}

enum CardParser {
    private static let cardPattern = #"<card>([\s\S]*?)</card>"#

    static func extract(from text: String) -> (displayText: String, card: ParsedActionCard?)? {
        guard let range = text.range(of: cardPattern, options: .regularExpression) else {
            return nil
        }
        let block = String(text[range])
        let inner = block
            .replacingOccurrences(of: "<card>", with: "")
            .replacingOccurrences(of: "</card>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let card = parseJSON(inner) ?? parseKeyValue(inner) {
            let display = text.replacingOccurrences(of: block, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            return (display, card)
        }
        return nil
    }

    private static func parseJSON(_ inner: String) -> ParsedActionCard? {
        guard let data = inner.data(using: .utf8),
              let json = try? JSONDecoder().decode(CardJSONPayload.self, from: data),
              !json.thought.isEmpty else { return nil }
        let actionsData = (try? JSONEncoder().encode(json.actions ?? [])).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        return ParsedActionCard(thought: json.thought, reframe: json.reframe, actions: actionsData)
    }

    private static func parseKeyValue(_ inner: String) -> ParsedActionCard? {
        var thought = ""
        var reframe = ""
        var actions = ""

        for line in inner.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("thought:") {
                thought = String(trimmed.dropFirst("thought:".count)).trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("reframe:") {
                reframe = String(trimmed.dropFirst("reframe:".count)).trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("actions:") {
                actions = String(trimmed.dropFirst("actions:".count)).trimmingCharacters(in: .whitespaces)
            }
        }

        guard !thought.isEmpty else { return nil }
        return ParsedActionCard(thought: thought, reframe: reframe, actions: actions)
    }
}
