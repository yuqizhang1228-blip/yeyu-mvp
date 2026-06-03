import SwiftUI

/// 对话内三选一引导（YUQ-46）
/// 设计稿：Figma `415:2362`（胶囊容器）
struct ChoiceGuideView: View {
    let onSelect: (String) -> Void

    private let options = [
        "更像憋屈或委屈，堵在胸口",
        "主要是焦虑，脑子停不下来",
        "我说不清，想用自己的话说",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 提示标签
            Text("哪种更接近你现在的感受？")
                .font(YeyuTypography.footnote)
                .foregroundStyle(Color.white.opacity(0.4))
                .padding(.horizontal, YeyuSpacing.lg)
                .padding(.top, YeyuSpacing.lg)
                .padding(.bottom, YeyuSpacing.md)

            // 选项列表
            VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
                ForEach(options, id: \.self) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        HStack(alignment: .top, spacing: YeyuSpacing.md) {
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                .frame(width: 12, height: 12)
                                .padding(.top, 3)
                            Text(option)
                                .font(YeyuTypography.body)
                                .foregroundStyle(.white)
                                .lineSpacing(3)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                }

                // 自由输入提示（非按钮，提示用户也可直接在输入框说）
                Text("或者其他你想说的？")
                    .font(YeyuTypography.body)
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(.horizontal, YeyuSpacing.lg)
            .padding(.bottom, YeyuSpacing.lg)
        }
        .background(YeyuColor.backgroundSheet)
        .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.promptCard))
        .overlay(
            RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)
        )
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.bottom, YeyuSpacing.sm)
    }
}
