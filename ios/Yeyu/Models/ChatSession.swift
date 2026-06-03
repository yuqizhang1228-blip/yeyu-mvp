import Foundation
import SwiftData

@Model
final class ChatSession {
    @Attribute(.unique) var id: UUID
    var title: String
    /// 本轮是否已完成三选一引导（YUQ-46）
    var choiceGuideCompleted: Bool = false
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ChatMessage.session)
    var messages: [ChatMessage]

    init(
        id: UUID = UUID(),
        title: String = "新对话",
        choiceGuideCompleted: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.choiceGuideCompleted = choiceGuideCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = []
    }
}

@Model
final class ChatMessage {
    @Attribute(.unique) var id: UUID
    var role: String
    var content: String
    var createdAt: Date
    var session: ChatSession?

    init(id: UUID = UUID(), role: MessageRole, content: String, createdAt: Date = .now) {
        self.id = id
        self.role = role.rawValue
        self.content = content
        self.createdAt = createdAt
    }

    var messageRole: MessageRole {
        MessageRole(rawValue: role) ?? .user
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}
