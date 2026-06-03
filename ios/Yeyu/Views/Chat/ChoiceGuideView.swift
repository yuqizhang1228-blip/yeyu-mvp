import SwiftUI

/// AI 引导选项卡（YUQ-52）
/// 选项由 AI 输出的 <choices> 标签解析而来，不再写死。
/// 设计稿：Figma `415:2362`（胶囊容器）
struct ChoiceGuideView: View {
    /// 由 ChoicesParser 解析的动态选项（最多 3 项）
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 提示标签
            Text("有几个方向，选一个？")
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
