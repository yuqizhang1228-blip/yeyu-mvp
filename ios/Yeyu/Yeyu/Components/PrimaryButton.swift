import SwiftUI

/// 夜屿主按钮 — 橙色渐变胶囊，带光晕和按压缩放反馈
/// 触控目标 ≥44pt（实际高度 52pt），满足 WCAG 触控规范
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            guard !isLoading else { return }
            action()
        } label: {
            HStack(spacing: Yeyu.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(Color.YY.background)
                        .frame(width: 18, height: 18)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(Yeyu.Typography.heading)
                }
            }
            .foregroundColor(Color.YY.background)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.YY.glowPrimary, Color.YY.glowSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.YY.glowPrimary.opacity(0.45), radius: 20, x: 0, y: 8)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(Yeyu.Anim.micro, value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        // 按压状态跟踪（微交互反馈）
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(isLoading ? "加载中，请稍候" : title)
        .accessibilityAddTraits(isLoading ? .updatesFrequently : [])
    }
}

// MARK: - Secondary Button

/// 次级按钮 — 液态玻璃描边风格
struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Yeyu.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                }
                Text(title)
                    .font(Yeyu.Typography.heading)
            }
            .foregroundColor(Color.YY.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.YY.lgFill)
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.YY.lgStroke, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(Yeyu.Anim.micro, value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressed { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(title)
    }
}

// MARK: - Icon Button (≥44pt target)

/// 图标按钮（导航、功能键），触控目标 44×44pt
struct IconButton: View {
    let systemName: String
    let accessibilityLabel: String
    var color: Color = Color.YY.textPrimary
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview

#Preview("Buttons") {
    VStack(spacing: Yeyu.Spacing.xl) {
        PrimaryButton(title: "开始对话") {}
        PrimaryButton(title: "发送", icon: "arrow.up") {}
        PrimaryButton(title: "加载中", isLoading: true) {}
        SecondaryButton(title: "查看历史", icon: "clock") {}
        HStack(spacing: Yeyu.Spacing.xl) {
            IconButton(systemName: "chevron.left", accessibilityLabel: "返回") {}
            IconButton(systemName: "plus", accessibilityLabel: "新对话",
                       color: Color.YY.glowPrimary) {}
            IconButton(systemName: "ellipsis", accessibilityLabel: "更多",
                       color: Color.YY.textSecondary) {}
        }
    }
    .padding(Yeyu.Spacing.xl)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.YY.background)
    .preferredColorScheme(.dark)
}
