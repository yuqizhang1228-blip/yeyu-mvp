import Foundation

// MARK: - Chat Message

/// 对话消息模型，兼容 DeepSeek / OpenAI Chat Completions 协议格式
struct ChatMessage: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let role: Role
    var content: String

    enum Role: String, Codable, CaseIterable {
        case system
        case user
        case assistant
    }

    /// 转换为 API 请求体格式（仅 role + content，不含 id）
    var apiDict: [String: String] {
        ["role": role.rawValue, "content": content]
    }
}

// MARK: - Yeyu Card

/// 行动卡片（从 AI 回复的 <card>...</card> 标签中解析）
struct YeyuCard: Codable, Identifiable {
    var id: UUID = UUID()
    let thought: String
    let reframe: String
    let actions: [String]
    var createdAt: Date = Date()

    /// 卡片是否有效（三个字段均非空）
    var isValid: Bool {
        !thought.isEmpty && !reframe.isEmpty && !actions.isEmpty
    }
}

// MARK: - Chat Session

/// 单次对话会话（包含消息历史和可选卡片）
struct ChatSession: Codable, Identifiable {
    var id: UUID = UUID()
    var messages: [ChatMessage] = []
    var card: YeyuCard? = nil
    var createdAt: Date = Date()
    /// 自动从首条用户消息截取的标题（最多 20 字）
    var title: String = ""

    mutating func appendMessage(_ message: ChatMessage) {
        messages.append(message)
        if title.isEmpty, message.role == .user {
            title = String(message.content.prefix(20))
        }
    }

    /// 该会话是否已生成卡片
    var hasCard: Bool { card != nil }

    /// 对话轮数（用户消息数量）
    var userTurns: Int { messages.filter { $0.role == .user }.count }
}
