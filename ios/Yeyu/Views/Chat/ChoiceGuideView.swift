import SwiftUI

/// 对话内三选一引导（YUQ-46）
struct ChoiceGuideView: View {
    let onSelect: (String) -> Void

    private let options = [
        "更像憋屈或委屈，堵在胸口",
        "主要是焦虑，脑子停不下来",
        "我说不清，想用自己的话说",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.md) {
            Text("哪种更接近你现在的感受？")
                .font(YeyuTypography.footnote)
                .foregroundStyle(YeyuColor.textTertiary)

            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    Text(option)
                        .font(YeyuTypography.body)
                        .foregroundStyle(YeyuColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, YeyuSpacing.lg)
                        .padding(.vertical, YeyuSpacing.md)
                        .background(YeyuColor.backgroundSurface)
                        .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: YeyuRadius.lg)
                                .stroke(YeyuColor.borderFocus, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.bottom, YeyuSpacing.sm)
    }
}
