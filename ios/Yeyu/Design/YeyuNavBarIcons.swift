import SwiftUI

/// 0515 顶栏图标（几何对齐 Figma 导出，原生绘制 → 任何机型都可见、可染色）。
/// 注：早前用 stroke-based SVG 资源（`NavIconMenu/Add`）在真机不可见——
/// Xcode 资源目录的 SVG 仅可靠支持 fill，不支持 stroke，故改原生 `Shape` 描边/填充。
/// - Menu：`226:2480` / 首页 `411:2022`
/// - Add：`226:2482` `icon/add`
enum YeyuNavBarIcon {
    /// Figma Nav bar `226:2479`：左右 icon 均为 24×24
    static let size: CGFloat = 24
    /// `px-[20px] py-[13px]`
    static let barVerticalPadding: CGFloat = 13
}

/// 左侧抽屉菜单 icon（Figma Menu Icon · `226:2480`）：三横线，顶/中满宽、底部短，线宽 1.5 圆头。
struct YeyuNavMenuIcon: View {
    var tint: Color = Color.white.opacity(0.80)

    var body: some View {
        VStack(alignment: .leading, spacing: 4.5) {
            bar(width: 16)
            bar(width: 16)
            bar(width: 9.5)
        }
        .frame(width: YeyuNavBarIcon.size, height: YeyuNavBarIcon.size)
        .accessibilityHidden(true)
    }

    private func bar(width: CGFloat) -> some View {
        Capsule(style: .continuous)
            .fill(tint)
            .frame(width: width, height: 1.5)
    }
}

// MARK: - 抽屉列表线性 icon（严格用设计稿导出的矢量路径 226:2418）

/// 设计稿导出的线性 icon（stroke-based + CSS 变量，Xcode 资源目录无法渲染）→
/// 直接吃 Figma 的 SVG path `d` 串，运行时解析为 SwiftUI Path 描边，几何 100% 对齐、可染色。
enum YeyuVectorIcon {
    case heart, pencil, tag, gear, chevron

    var viewBox: CGSize {
        switch self {
        case .heart:   return CGSize(width: 17.0483, height: 14.7062)
        case .pencil:  return CGSize(width: 20, height: 20)
        case .tag:     return CGSize(width: 17, height: 17)
        case .gear:    return CGSize(width: 16, height: 17.6667)
        case .chevron: return CGSize(width: 20, height: 20)
        }
    }

    var d: String {
        switch self {
        case .heart:
            return "M1.67115 1.72115C2.42126 0.971268 3.43849 0.550007 4.49914 0.550007C5.5598 0.550007 6.57703 0.971268 7.32714 1.72115L8.49914 2.89215L9.67114 1.72115C10.0401 1.33911 10.4815 1.03438 10.9695 0.824747C11.4575 0.615111 11.9824 0.504766 12.5135 0.500151C13.0447 0.495536 13.5714 0.596743 14.063 0.797866C14.5545 0.99899 15.0012 1.296 15.3767 1.67157C15.7523 2.04714 16.0493 2.49375 16.2504 2.98534C16.4516 3.47692 16.5528 4.00364 16.5481 4.53476C16.5435 5.06587 16.4332 5.59076 16.2235 6.07877C16.0139 6.56679 15.7092 7.00817 15.3271 7.37715L8.49914 14.2062L1.67115 7.37715C0.921261 6.62704 0.5 5.60981 0.5 4.54915C0.5 3.4885 0.921261 2.47126 1.67115 1.72115V1.72115Z"
        case .pencil:
            return "M10 18.5H18M12.5 4L16 7M3.5 13L13.3595 2.79619C14.4211 1.7346 16.1422 1.7346 17.2038 2.79619C18.2654 3.85777 18.2654 5.57894 17.2038 6.64052L7 16.5L2 18L3.5 13Z"
        case .tag:
            return "M12.1283 4.87707L12.123 4.87704M14.7688 0.876162L9.93514 0.504344C9.50659 0.471379 9.08504 0.627321 8.78112 0.931241L0.931234 8.78113C0.356255 9.35611 0.356255 10.2883 0.931234 10.8633L6.13669 16.0688C6.71166 16.6437 7.64389 16.6437 8.21887 16.0688L16.0688 8.21887C16.3727 7.91495 16.5286 7.4934 16.4957 7.06486L16.1238 2.23123C16.0681 1.50717 15.4928 0.931859 14.7688 0.876162Z"
        case .gear:
            return "M15.5 4.66667L8 0.5L0.5 4.66667V13L8 17.1667L15.5 13V4.66667ZM8 11.6111C9.59431 11.6111 10.8868 10.3675 10.8868 8.83333C10.8868 7.29921 9.59431 6.05556 8 6.05556C6.40569 6.05556 5.11325 7.29921 5.11325 8.83333C5.11325 10.3675 6.40569 11.6111 8 11.6111Z"
        case .chevron:
            return "M6.25 2.50002L13.75 10L6.25 17.5"
        }
    }
}

/// 把 SVG path（仅 M/L/H/V/C/Z 绝对命令）解析为 SwiftUI Path，并等比居中缩放到 rect。
struct YeyuVectorIconShape: Shape {
    let icon: YeyuVectorIcon

    func path(in rect: CGRect) -> Path {
        var raw = Path()
        Self.build(icon.d, into: &raw)
        let vb = icon.viewBox
        let s = min(rect.width / vb.width, rect.height / vb.height)
        let tx = (rect.width - vb.width * s) / 2
        let ty = (rect.height - vb.height * s) / 2
        return raw.applying(CGAffineTransform(translationX: tx, y: ty).scaledBy(x: s, y: s))
    }

    private enum Tok { case cmd(Character); case num(CGFloat) }

    private static func build(_ d: String, into path: inout Path) {
        let toks = tokenize(d)
        var i = 0
        var cur = CGPoint.zero
        var startPt = CGPoint.zero
        var cmd: Character = " "
        func num() -> CGFloat {
            while i < toks.count { if case let .num(v) = toks[i] { i += 1; return v }; i += 1 }
            return 0
        }
        while i < toks.count {
            if case let .cmd(c) = toks[i] { cmd = c; i += 1; if cmd == "Z" || cmd == "z" { path.closeSubpath(); cur = startPt; continue } }
            switch cmd {
            case "M":
                let x = num(); let y = num(); cur = CGPoint(x: x, y: y); startPt = cur
                path.move(to: cur); cmd = "L"
            case "L":
                let x = num(); let y = num(); cur = CGPoint(x: x, y: y); path.addLine(to: cur)
            case "H":
                cur.x = num(); path.addLine(to: cur)
            case "V":
                cur.y = num(); path.addLine(to: cur)
            case "C":
                let x1 = num(); let y1 = num(); let x2 = num(); let y2 = num(); let x = num(); let y = num()
                cur = CGPoint(x: x, y: y)
                path.addCurve(to: cur, control1: CGPoint(x: x1, y: y1), control2: CGPoint(x: x2, y: y2))
            default:
                i += 1
            }
        }
    }

    private static func tokenize(_ d: String) -> [Tok] {
        var toks: [Tok] = []
        let chars = Array(d)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if c.isLetter {
                toks.append(.cmd(c)); i += 1
            } else if c == " " || c == "," || c == "\n" || c == "\t" {
                i += 1
            } else {
                var j = i
                if chars[j] == "-" || chars[j] == "+" { j += 1 }
                while j < chars.count {
                    let ch = chars[j]
                    if ch.isNumber || ch == "." { j += 1 }
                    else if ch == "e" || ch == "E" {
                        j += 1
                        if j < chars.count, chars[j] == "-" || chars[j] == "+" { j += 1 }
                    } else { break }
                }
                if let v = Double(String(chars[i..<j])) { toks.append(.num(CGFloat(v))) }
                i = max(j, i + 1)
            }
        }
        return toks
    }
}

/// 线性 icon 视图：等比居中描边，圆头圆角。
struct YeyuVectorIconView: View {
    let icon: YeyuVectorIcon
    var size: CGFloat = 20
    var lineWidth: CGFloat = 1.6
    var tint: Color = .white

    var body: some View {
        YeyuVectorIconShape(icon: icon)
            .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// 右侧新建对话 icon（Figma `icon/add` · `226:2482`）：圆角方框 + 居中加号。
struct YeyuNavAddIcon: View {
    var tint: Color = YeyuColor.textPrimary

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3.375, style: .continuous)
                .stroke(tint, lineWidth: 1.5)
                .frame(width: 18, height: 18)
            Capsule().fill(tint).frame(width: 6.75, height: 1.5)
            Capsule().fill(tint).frame(width: 1.5, height: 6.75)
        }
        .frame(width: YeyuNavBarIcon.size, height: YeyuNavBarIcon.size)
        .accessibilityHidden(true)
    }
}
