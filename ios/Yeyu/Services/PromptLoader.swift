import Foundation

enum PromptLoader {
    static func load(_ name: String, replacements: [String: String] = [:]) -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: "md"),
              var text = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        for (key, value) in replacements {
            text = text.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return text
    }
}

enum SystemPrompt {
    static var production: String {
        let fromBundle = PromptLoader.load("system_production")
        if !fromBundle.isEmpty { return fromBundle }
        return "你是「夜屿」情绪梳理助手。请用中文进行温和、具体的情绪梳理。"
    }
}
