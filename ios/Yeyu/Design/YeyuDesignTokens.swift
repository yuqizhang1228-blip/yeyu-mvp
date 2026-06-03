import SwiftUI

/// 夜屿 Design Tokens
/// - **P0 运行时**：以下无 `0515` 后缀的名为当前默认（H5 早期 + 工程占位）。
/// - **0515 高保真**：`surfacePromptCard` 等为目标色；v1.1 视觉收口时把默认别名切到 0515，见 `ios/VISUAL_ROADMAP.md`。
enum YeyuColor {
    // MARK: P0 默认（勿在 View 中写 hex）

    static let backgroundBase = Color(hex: 0x0B111D)
    static let backgroundSurface = Color(hex: 0x161B22)
    static let backgroundElevated = Color(hex: 0x1A1F26)
    static let backgroundInput = Color(hex: 0x292F39)
    static let overlay = Color.black.opacity(0.80)

    static let primary = Color(hex: 0xFFB86C)
    static let primaryLight = Color(hex: 0xFFCF99)
    static let primaryMuted = Color(hex: 0xFFB86C).opacity(0.15)

    static let textTitle = Color(hex: 0xF2F5FF)
    static let textPrimary = Color(hex: 0xE0E7FF)
    static let textSecondary = Color(hex: 0xA9B2CC)
    static let textTertiary = Color(hex: 0x707A94)
    static let textInverse = Color(hex: 0x0B111D)

    static let borderDefault = Color.white.opacity(0.06)
    static let borderFocus = Color(hex: 0xFFB86C).opacity(0.5)

    static let error = Color(hex: 0xEF4444)

    // MARK: 0515 预留（Figma 夜屿 UI - 全界面/0515；P0 仅择优引用）

    /// 首页背景渐变顶色 · `page/home` background
    static let background0515Top = Color(hex: 0x0D0D0D)
    /// 首页背景渐变底色
    static let background0515Bottom = Color(hex: 0x313131)
    /// 快捷话题卡 / chat-prompt · `#252525`
    static let surfacePromptCard = Color(hex: 0x252525)
    static let borderPromptCard = Color.white.opacity(0.10)
    /// 输入大框描边（玻璃框）
    static let borderInput0515 = Color.white.opacity(1.0)
    /// 合规/辅助 · 10px 30% 白
    static let textCompliance = Color.white.opacity(0.30)
    /// 0515 主文案 80% 白
    static let textOnDarkSecondary = Color.white.opacity(0.80)
}

enum YeyuSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

enum YeyuRadius {
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    /// 0515 快捷卡、底部 input box
    static let promptCard: CGFloat = 24
    static let full: CGFloat = 9999
}

enum YeyuTypography {
    static let caption: Font = .system(size: 10)
    static let footnote: Font = .system(size: 12)
    static let body: Font = .system(size: 14)
    static let callout: Font = .system(size: 16)
    static let title: Font = .system(size: 22, weight: .semibold)
    /// 0515 首页主标题量级（26pt）；v1.1 换问候区时启用
    static let displayGreeting: Font = .system(size: 26, weight: .regular)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
