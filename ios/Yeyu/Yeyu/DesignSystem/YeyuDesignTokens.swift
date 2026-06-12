import SwiftUI

// MARK: - 夜屿 Design Tokens
// 三层架构：Primitive → Semantic → Component
// 对齐 Figma Variables：主色 #FF9F68，深色底 #12141E
// 对应 H5 CSS 变量（index.html :root），非旧版

// MARK: - Spacing, Radius, Blur, Shadow, Typography, Animation

enum Yeyu {

    // MARK: Spacing (px → pt，1:1 on standard density)
    enum Spacing {
        static let xs:   CGFloat = 4
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let base: CGFloat = 16
        static let lg:   CGFloat = 20
        static let xl:   CGFloat = 24
        static let xxl:  CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm:     CGFloat = 8
        static let md:     CGFloat = 12
        static let lg:     CGFloat = 16
        static let card:   CGFloat = 22   // --radius-card
        static let bubble: CGFloat = 22   // --radius-bubble
        static let pill:   CGFloat = 999  // --radius-pill
    }

    // MARK: Blur (backdrop-filter → material)
    enum Blur {
        static let base:   CGFloat = 40   // --lg-blur
        static let strong: CGFloat = 56   // --lg-blur-strong
    }

    // MARK: Typography
    // 中文衬线大标题用 Noto Serif SC，正文用系统字
    enum Typography {
        /// 大标题 — Noto Serif SC（与 H5 @import 保持一致）
        static let display = Font.custom("NotoSerifSC-Regular", size: 28)
            .weight(.regular)
        /// 页面/段落标题
        static let title   = Font.custom("NotoSerifSC-Regular", size: 22)
        /// 小标题 / 卡片标题
        static let heading = Font.system(size: 17, weight: .semibold)
        /// 正文（对话气泡）
        static let body    = Font.system(size: 15, weight: .regular)
        /// 辅助文字
        static let caption = Font.system(size: 13, weight: .regular)
        /// 标签 / 小标签
        static let label   = Font.system(size: 11, weight: .medium)

        static let bodyLineSpacing: CGFloat = 6
    }

    // MARK: Animation
    enum Anim {
        /// 微交互：按钮按压反馈（≈150ms）
        static let micro    = Animation.easeOut(duration: 0.15)
        /// 界面状态过渡（≈250ms）
        static let standard = Animation.easeInOut(duration: 0.25)
        /// 底部面板/侧抽屉滑入
        static let panel    = Animation.spring(response: 0.4, dampingFraction: 0.85)
    }
}

// MARK: - Color Tokens (extension on SwiftUI.Color)
// 用 Color.YeyuPalette 命名空间，避免与 Yeyu 顶层 enum 冲突

extension Color {
    enum YY {
        // ── 背景层 ──────────────────────────────────────────────
        /// 主背景 #12141E（对应 --bg: #12141e）
        static let background      = Color(hex: "#12141E")
        /// 卡片/容器底色 rgba(30,34,46,0.65)（--surface）
        static let surface         = Color(r: 30, g: 34, b: 46, a: 0.65)
        /// 次级容器底色 rgba(255,255,255,0.06)（--surface2）
        static let surfaceElevated = Color(white: 1, a: 0.06)

        // ── 文字 ─────────────────────────────────────────────────
        /// 主文字 #F1F5F9（--text-primary）
        static let textPrimary    = Color(hex: "#F1F5F9")
        /// 次要文字 #A1AEC0（--text-secondary）
        static let textSecondary  = Color(hex: "#A1AEC0")
        /// 弱文字 rgba(168,182,200,0.58)（--text-subtle）
        static let textSubtle     = Color(r: 168, g: 182, b: 200, a: 0.58)

        // ── 品牌色 ───────────────────────────────────────────────
        /// 主橙色 #FF9F68（--glow-primary）
        static let glowPrimary    = Color(hex: "#FF9F68")
        /// 次橙色 #FF7E5F（--glow-secondary）
        static let glowSecondary  = Color(hex: "#FF7E5F")
        /// 靛蓝色 #818CF8（--indigo）
        static let indigo         = Color(hex: "#818CF8")

        // ── 边框 / Ring ──────────────────────────────────────────
        /// 通用边框 rgba(255,255,255,0.11)（--border）
        static let border         = Color(white: 1, a: 0.11)
        /// Focus ring rgba(255,180,140,0.5)（--ring）
        static let ring           = Color(r: 255, g: 180, b: 140, a: 0.50)

        // ── 液态玻璃材质（Liquid Glass）────────────────────────────
        /// 弱填充 rgba(255,255,255,0.055)（--lg-fill）
        static let lgFill         = Color(white: 1, a: 0.055)
        /// 高亮填充 rgba(255,255,255,0.09)（--lg-fill-elevated）
        static let lgFillElevated = Color(white: 1, a: 0.09)
        /// 描边 rgba(255,255,255,0.14)（--lg-stroke）
        static let lgStroke       = Color(white: 1, a: 0.14)
        /// 柔和描边 rgba(255,255,255,0.09)（--lg-stroke-soft）
        static let lgStrokeSoft   = Color(white: 1, a: 0.09)
        /// 高光 rgba(255,255,255,0.22)（--lg-specular）
        static let lgSpecular     = Color(white: 1, a: 0.22)

        // ── Shadow ───────────────────────────────────────────────
        /// 卡片阴影色 rgba(0,0,0,0.45)（--lg-shadow）
        static let shadow         = Color(white: 0, a: 0.45)
    }
}

// MARK: - Color Initializer Helpers

extension Color {
    /// 从 HEX 字符串创建颜色（#RGB、#RRGGBB、#AARRGGBB）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // AARRGGBB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }

    /// 从 0-255 RGB + 0-1 alpha 创建颜色（方便内部 Token 定义）
    fileprivate init(r: Double, g: Double, b: Double, a: Double) {
        self.init(.sRGB, red: r / 255, green: g / 255, blue: b / 255, opacity: a)
    }

    /// 白色 / 黑色 + alpha（white = 1 → 白，white = 0 → 黑）
    fileprivate init(white: Double, a: Double) {
        self.init(.sRGB, red: white, green: white, blue: white, opacity: a)
    }
}

// MARK: - Liquid Glass ViewModifier

/// 液态玻璃材质修饰符（毛玻璃背景 + 描边 + 阴影）
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = Yeyu.Radius.card
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(elevated ? Color.YY.lgFillElevated : Color.YY.lgFill)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.YY.lgStroke, lineWidth: 0.5)
                    )
                    .shadow(color: Color.YY.shadow, radius: 24, x: 0, y: 12)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    /// 应用液态玻璃材质
    func liquidGlass(cornerRadius: CGFloat = Yeyu.Radius.card, elevated: Bool = false) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, elevated: elevated))
    }
}
