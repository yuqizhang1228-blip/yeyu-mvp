import Foundation

/// AI 引导选项解析（YUQ-52）
/// AI 在探针阶段末尾输出 <choices>["A","B","C"]</choices>，客户端解析后显示为可点击选项卡
enum ChoicesParser {
    private static let pattern = #"<choices>(\[[\s\S]*?\])</choices>"#

    /// 从 AI 回复中提取选项数组，无则返回 nil
    static func extract(from text: String) -> [String]? {
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        let block = String(text[range])
        let inner = block
            .replacingOccurrences(of: "<choices>", with: "")
            .replacingOccurrences(of: "</choices>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = inner.data(using: .utf8),
              let arr = try? JSONDecoder().decode([String].self, from: data),
              !arr.isEmpty else { return nil }
        return arr
    }

    /// 从文本中移除 <choices>…</choices> 块，返回干净的展示文本
    static func strip(from text: String) -> String {
        text.replacingOccurrences(of: #"<choices>[\s\S]*?</choices>"#,
                                  with: "",
                                  options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
