import SwiftUI

/// AI 引导选项卡（YUQ-52）
/// 选项由 AI 输出的 <choices> 标签解析而来，不再写死。
/// 设计稿：Figma `415:2362`（胶囊容器）
struct ChoiceGuideView: View {
    /// 由 ChoicesParser 解析的动态选项（最多 3 项）
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.lg) {
            // 选项列表（点选即发送，单选圈为视觉一致，不做预选）
            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack(alignment: .top, spacing: YeyuSpacing.md) {
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 16, height: 16)
                            .padding(.top, 2)
                        Text(option)
                            .font(YeyuTypography.body)
                            .foregroundStyle(.white)
                            .lineSpacing(3)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            // 「或者其他你想说的?」——提示可直接在下方输入框自由表达（对齐 415:2362）
            Text("或者其他你想说的?")
                .font(YeyuTypography.body)
                .foregroundStyle(Color.white.opacity(0.35))
                .padding(.top, YeyuSpacing.xs)
        }
        .padding(YeyuSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .yeyuGlass(cornerRadius: YeyuRadius.promptCard)
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.bottom, YeyuSpacing.sm)
    }
}
