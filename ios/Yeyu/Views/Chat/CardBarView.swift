import SwiftUI

/// 保存卡片后的折叠条（对齐 H5 cardBar）
struct CardBarView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: YeyuSpacing.md) {
                Circle()
                    .fill(YeyuColor.primary)
                    .frame(width: 8, height: 8)
                Text("已为你保存一张行动卡片 · 点击查看")
                    .font(YeyuTypography.footnote)
                    .foregroundStyle(YeyuColor.textSecondary)
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(YeyuColor.primary)
            }
            .padding(.horizontal, YeyuSpacing.lg)
            .padding(.vertical, YeyuSpacing.md)
            .background(YeyuColor.backgroundSurface)
            .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: YeyuRadius.lg)
                    .stroke(YeyuColor.borderFocus, lineWidth: 1)
            )
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.bottom, YeyuSpacing.sm)
    }
}
