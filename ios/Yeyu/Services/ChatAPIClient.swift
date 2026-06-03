import Foundation

struct ChatAPIClient {
    /// 生产代理 — Key 仅在 Vercel 服务端（YUQ-42）
    var baseURL = URL(string: "https://yeyu-mvp.vercel.app/api/chat")!
    /// v1 使用整包响应；v1.1 改 true 开启 SSE 打字机效果（YUQ-47）
    var prefersStreaming = false

    struct ChatRequest: Encodable {
        let model: String
        let messages: [APIMessage]
        let temperature: Double
        let max_tokens: Int
        let top_p: Double
        let stream: Bool?
    }

    struct APIMessage: Encodable {
        let role: String
        let content: String
    }

    struct ChatResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable {
                let content: String?
            }
            let message: Message?
        }
        let choices: [Choice]?
        let error: APIErrorBody?
    }

    struct APIErrorBody: Decodable {
        let error: String?
    }

    func send(
        messages: [APIMessage],
        systemPrompt: String,
        extraSystemMessages: [String] = [],
        maxTokens: Int = 500
    ) async throws -> String {
        let payload = try buildPayload(
            messages: messages,
            systemPrompt: systemPrompt,
            extraSystemMessages: extraSystemMessages,
            maxTokens: maxTokens,
            stream: false
        )

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw ChatAPIError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        if http.statusCode >= 400 {
            throw ChatAPIError.server(decoded.error?.error ?? "HTTP \(http.statusCode)")
        }
        guard let content = decoded.choices?.first?.message?.content, !content.isEmpty else {
            throw ChatAPIError.emptyContent
        }
        return content
    }

    /// 消费 DeepSeek 兼容 SSE（经 `/api/chat` 透传）
    func sendStream(
        messages: [APIMessage],
        systemPrompt: String,
        extraSystemMessages: [String] = [],
        maxTokens: Int = 500
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let payload = try buildPayload(
                        messages: messages,
                        systemPrompt: systemPrompt,
                        extraSystemMessages: extraSystemMessages,
                        maxTokens: maxTokens,
                        stream: true
                    )
                    var request = URLRequest(url: baseURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.httpBody = try JSONEncoder().encode(payload)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse else {
                        throw ChatAPIError.invalidResponse
                    }
                    if http.statusCode >= 400 {
                        throw ChatAPIError.server("HTTP \(http.statusCode)")
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6))
                        if payload == "[DONE]" { break }
                        if let chunk = Self.parseSSEDelta(payload) {
                            continuation.yield(chunk)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func buildPayload(
        messages: [APIMessage],
        systemPrompt: String,
        extraSystemMessages: [String],
        maxTokens: Int,
        stream: Bool
    ) throws -> ChatRequest {
        var payload: [APIMessage] = []
        if !systemPrompt.isEmpty {
            payload.append(APIMessage(role: "system", content: systemPrompt))
        }
        for line in extraSystemMessages where !line.isEmpty {
            payload.append(APIMessage(role: "system", content: line))
        }
        payload.append(contentsOf: messages)

        return ChatRequest(
            model: "deepseek-chat",
            messages: payload,
            temperature: 0.7,
            max_tokens: maxTokens,
            top_p: 0.9,
            stream: stream ? true : nil
        )
    }

    private static func parseSSEDelta(_ jsonLine: String) -> String? {
        guard let data = jsonLine.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let delta = choices.first?["delta"] as? [String: Any],
              let content = delta["content"] as? String,
              !content.isEmpty else {
            return nil
        }
        return content
    }
}

enum ChatAPIError: LocalizedError {
    case invalidResponse
    case emptyContent
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "网络响应无效"
        case .emptyContent: return "AI 返回为空"
        case .server(let msg): return msg
        }
    }
}
