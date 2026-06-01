import Foundation

// MARK: - ChatAPIClient

/// 网络层：调用 https://yeyu-mvp.vercel.app/api/chat（Vercel Serverless 代理）
/// DEBUG 模式支持切换到本地开发服务器（localhost:3000）
/// 本地 HTTP 请求需要在 Info.plist 中设置 NSAllowsLocalNetworking = YES
@MainActor
final class ChatAPIClient: ObservableObject {

    // MARK: - Singleton

    static let shared = ChatAPIClient()

    // MARK: - Config

    private let productionURL = URL(string: "https://yeyu-mvp.vercel.app/api/chat")!
    private let localDevURL   = URL(string: "http://localhost:3000/api/chat")!

    /// DEBUG 时可切换为本地服务器（需要 NSAllowsLocalNetworking）
    var useLocalServer: Bool = false

    private var baseURL: URL {
#if DEBUG
        return useLocalServer ? localDevURL : productionURL
#else
        return productionURL
#endif
    }

    // MARK: - State

    @Published var isSending: Bool = false

    // MARK: - URLSession

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 60
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        return URLSession(configuration: config)
    }()

    private init() {}

    // MARK: - Send Message

    /// 发送对话消息并返回 AI 回复内容
    /// - Parameters:
    ///   - messages:      当前会话的消息历史（不含 system prompt）
    ///   - systemPrompt:  对话 System Prompt（来自 prompts/ 目录）
    /// - Returns:         AI 回复的纯文本内容
    func sendMessage(
        messages: [ChatMessage],
        systemPrompt: String
    ) async throws -> String {
        isSending = true
        defer { isSending = false }

        // 构造完整消息列表（system 在首位）
        var fullMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        fullMessages.append(contentsOf: messages.map(\.apiDict))

        let body = ChatRequestBody(
            messages: fullMessages,
            model: "deepseek-chat",
            temperature: 0.7,
            topP: 0.9,
            maxTokens: 500
        )

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw YeyuAPIError.invalidResponse
        }

        guard http.statusCode == 200 else {
            let errBody = try? JSONDecoder().decode(APIErrorBody.self, from: data)
            throw YeyuAPIError.httpError(statusCode: http.statusCode,
                                          message: errBody?.error)
        }

        let chatResponse = try JSONDecoder().decode(ChatResponseBody.self, from: data)

        guard let content = chatResponse.choices.first?.message.content,
              !content.isEmpty else {
            throw YeyuAPIError.emptyResponse
        }

        return content
    }

    // MARK: - Card Parsing

    /// 从 AI 回复文本中解析 `<card>...</card>` 标签内嵌的 JSON
    nonisolated func parseCard(from text: String) -> YeyuCard? {
        guard let range = text.range(of: #"<card>([\s\S]*?)</card>"#,
                                      options: .regularExpression) else {
            return nil
        }
        // 提取标签内的 JSON 字符串
        var json = String(text[range])
        json = json
            .replacingOccurrences(of: "<card>", with: "")
            .replacingOccurrences(of: "</card>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = json.data(using: .utf8),
              let raw = try? JSONDecoder().decode(RawCardJSON.self, from: data) else {
            return nil
        }

        return YeyuCard(thought: raw.thought, reframe: raw.reframe, actions: raw.actions)
    }

    // MARK: - Crisis Detection（安全边界，不可删除）

    /// 危机关键词列表（对应 H5 端安全边界逻辑）
    static let crisisKeywords: [String] = [
        "不想活了", "想消失", "不知道活着有什么意思",
        "活着没意思", "结束生命", "死了算了"
    ]
    static let crisisHotline = "400-161-9995"

    /// 检测文本是否触发安全边界
    nonisolated func detectCrisis(in text: String) -> Bool {
        Self.crisisKeywords.contains { text.contains($0) }
    }
}

// MARK: - Request/Response Codable Models

private struct ChatRequestBody: Encodable {
    let messages: [[String: String]]
    let model: String
    let temperature: Double
    let topP: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case messages, model, temperature
        case topP     = "top_p"
        case maxTokens = "max_tokens"
    }
}

private struct ChatResponseBody: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let role: String
        let content: String
    }
}

private struct APIErrorBody: Decodable {
    let error: String
}

private struct RawCardJSON: Decodable {
    let thought: String
    let reframe: String
    let actions: [String]
}

// MARK: - Error Types

enum YeyuAPIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case emptyResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务器返回了无效的响应格式"
        case .httpError(let code, let msg):
            if let msg { return "请求失败（\(code)）：\(msg)" }
            return "请求失败，状态码：\(code)"
        case .emptyResponse:
            return "AI 未返回内容，请重试"
        case .decodingError(let err):
            return "数据解析错误：\(err.localizedDescription)"
        }
    }
}
