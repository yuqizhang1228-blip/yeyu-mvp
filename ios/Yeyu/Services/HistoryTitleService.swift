import Foundation

enum HistoryTitleService {
    static func generateTitle(for messages: [ChatMessage]) async -> String? {
        guard messages.contains(where: { $0.messageRole == .user }),
              messages.contains(where: { $0.messageRole == .assistant }) else {
            return nil
        }

        let system = PromptLoader.load("history_title_system")
        let apiMessages = messages.sorted { $0.createdAt < $1.createdAt }.map {
            ChatAPIClient.APIMessage(
                role: $0.messageRole == .user ? "user" : "assistant",
                content: $0.content
            )
        }

        let client = ChatAPIClient()
        do {
            var payload = apiMessages
            payload.append(.init(role: "user", content: "请为这段对话生成标题。"))
            let title = try await client.send(
                messages: payload,
                systemPrompt: system,
                maxTokens: 60
            )
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : String(trimmed.prefix(20))
        } catch {
            return nil
        }
    }
}
