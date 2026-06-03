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
    /// 输入大框玻璃底 · linear-gradient(93°, white10 → white08)（411:2006）
    static let inputGlassTop = Color.white.opacity(0.10)
    static let inputGlassBottom = Color.white.opacity(0.08)
    /// 输入框占位文案 60% 白（411:2007）
    static let textPlaceholder0515 = Color.white.opacity(0.60)
    /// 合规/辅助 · 10px 30% 白
    static let textCompliance = Color.white.opacity(0.30)
    /// 0515 主文案 80% 白
    static let textOnDarkSecondary = Color.white.opacity(0.80)

    // MARK: 首页输入框内 icon（0515 · 411:2008 / 411:2013）
    /// 模型 icon 圆底 · white 10%
    static let iconModelBackground = Color.white.opacity(0.10)
    /// 模型 icon「+」描线 · #D9D9D9
    static let iconModelGlyph = Color(hex: 0xD9D9D9)
    /// 语音 icon 圆底 · #F9F9F9
    static let iconVoiceBackground = Color(hex: 0xF9F9F9)
    /// 语音 icon 波形/箭头 · #212121
    static let iconVoiceGlyph = Color(hex: 0x212121)

    // MARK: Sheet / 卡片弹窗（0515 · 394:2232）
    /// 出卡弹窗底板 `#2C2C2C`
    static let backgroundSheet = Color(hex: 0x2C2C2C)
    /// 行动卡片 hero 块 `#383838`
    static let surfaceActionCard = Color(hex: 0x383838)

    // MARK: 侧抽屉（0515 · 226:2399）
    /// 抽屉底板（暖深灰，模拟 blur+overlay 效果）
    static let backgroundDrawer = Color(hex: 0x1A1A1A)
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

/// 夜屿液态玻璃材质封装
/// - **iOS 26+**：系统 **Liquid Glass**（`.glassEffect`），自动适配「降低透明度 / 减弱动效」等无障碍设置。
/// - **iOS 17–25**：回退到手绘玻璃（白渐变底 + 1px 描边），与 0515 稿一致。
///
/// 约束：玻璃不可叠玻璃；玻璃容器内的小控件用纯色/淡色圆底，勿再套 `glassEffect`。
extension View {
    @ViewBuilder
    func yeyuGlass(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                interactive ? .regular.interactive() : .regular,
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
        } else {
            self
                .background(
                    LinearGradient(
                        colors: [YeyuColor.inputGlassTop, YeyuColor.inputGlassBottom],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: cornerRadius)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
    }
}
