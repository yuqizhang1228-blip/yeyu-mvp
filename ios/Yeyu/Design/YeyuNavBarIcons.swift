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
