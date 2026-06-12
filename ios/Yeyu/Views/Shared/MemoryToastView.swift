import SwiftUI

/// 顶部「已加入记忆」气泡：深色玻璃胶囊 + 小图标，从设备顶部自上而下滑入、自动消失。
/// 由 `RootView` 顶部 overlay 驱动，置于导航栈与 sheet 之上。
struct MemoryToastView: View {
    let toast: AppState.MemoryToast

    private var iconName: String {
        toast.kind == .added ? "sparkles" : "arrow.triangle.2.circlepath"
    }

    var body: some View {
        HStack(spacing: YeyuSpacing.sm) {
            Image(systemName: iconName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(YeyuColor.primary)
            Text(toast.text)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, YeyuSpacing.lg)
        .padding(.vertical, YeyuSpacing.sm + 2)
        .yeyuDarkGlass(in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
        .padding(.top, YeyuSpacing.sm)
        .transition(.move(edge: .top).combined(with: .opacity))
        .sensoryFeedback(.success, trigger: toast.id)
        .accessibilityLabel(toast.text)
    }
}
