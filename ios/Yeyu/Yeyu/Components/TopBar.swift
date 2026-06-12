import SwiftUI

/// 夜屿顶部导航栏 — 液态玻璃底，左右 44pt 按钮，居中标题
/// 配合 SafeArea 顶部内边距，兼容刘海/灵动岛
struct TopBar: View {
    var title: String = ""
    var titleFont: Font = Yeyu.Typography.heading

    // 左侧按钮
    var leadingIcon: String = "chevron.left"
    var leadingLabel: String = "返回"
    var showLeading: Bool = false
    var onLeading: (() -> Void)? = nil

    // 右侧按钮（可选）
    var trailingIcon: String = "ellipsis"
    var trailingLabel: String = "更多"
    var showTrailing: Bool = false
    var onTrailing: (() -> Void)? = nil

    var body: some View {
        ZStack {
            // 背景：液态玻璃 + 底部分割线
            Color.YY.lgFill
                .overlay(alignment: .bottom) {
                    Color.YY.lgStrokeSoft
                        .frame(height: 0.5)
                }

            HStack(spacing: 0) {
                // Leading
                Group {
                    if showLeading {
                        Button {
                            onLeading?()
                        } label: {
                            Image(systemName: leadingIcon)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color.YY.textPrimary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(leadingLabel)
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }

                Spacer()

                // Title
                if !title.isEmpty {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(Color.YY.textPrimary)
                        .lineLimit(1)
                }

                Spacer()

                // Trailing
                Group {
                    if showTrailing {
                        Button {
                            onTrailing?()
                        } label: {
                            Image(systemName: trailingIcon)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color.YY.textSecondary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(trailingLabel)
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.horizontal, Yeyu.Spacing.sm)
        }
        .frame(height: 52)
    }
}

// MARK: - 带自定义 trailing 内容的扩展版 TopBar

struct TopBarWithTrailingContent<TrailingContent: View>: View {
    var title: String = ""
    var showLeading: Bool = false
    var onLeading: (() -> Void)? = nil
    var leadingIcon: String = "chevron.left"
    var leadingLabel: String = "返回"
    @ViewBuilder var trailingContent: () -> TrailingContent

    var body: some View {
        ZStack {
            Color.YY.lgFill
                .overlay(alignment: .bottom) {
                    Color.YY.lgStrokeSoft.frame(height: 0.5)
                }

            HStack(spacing: 0) {
                Group {
                    if showLeading {
                        Button {
                            onLeading?()
                        } label: {
                            Image(systemName: leadingIcon)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color.YY.textPrimary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(leadingLabel)
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }

                Spacer()

                if !title.isEmpty {
                    Text(title)
                        .font(Yeyu.Typography.heading)
                        .foregroundColor(Color.YY.textPrimary)
                        .lineLimit(1)
                }

                Spacer()

                trailingContent()
                    .frame(height: 44)
            }
            .padding(.horizontal, Yeyu.Spacing.sm)
        }
        .frame(height: 52)
    }
}

// MARK: - Preview

#Preview("TopBar Variants") {
    VStack(spacing: 0) {
        // 1. 纯标题
        TopBar(title: "夜屿")

        // 2. 带返回按钮
        TopBar(
            title: "今晚聊什么",
            showLeading: true,
            onLeading: {}
        )

        // 3. 带返回 + 更多
        TopBar(
            title: "对话详情",
            showLeading: true,
            onLeading: {},
            showTrailing: true,
            onTrailing: {}
        )

        // 4. 首页 TopBar（右侧自定义内容）
        TopBarWithTrailingContent(title: "夜屿") {
            HStack(spacing: Yeyu.Spacing.xs) {
                IconButton(systemName: "clock", accessibilityLabel: "历史") {}
                IconButton(systemName: "gearshape", accessibilityLabel: "设置") {}
            }
        }

        Spacer()
    }
    .background(Color.YY.background)
    .preferredColorScheme(.dark)
}
