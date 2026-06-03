import SwiftUI

/// 关于夜屿（YUQ-38）
struct AboutView: View {
    var body: some View {
        ZStack {
            YeyuColor.backgroundBase.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: YeyuSpacing.xxl) {

                    VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                        Text("夜屿")
                            .font(YeyuTypography.displayGreeting)
                            .foregroundStyle(YeyuColor.textTitle)
                        Text("Night Isle")
                            .font(YeyuTypography.body)
                            .foregroundStyle(YeyuColor.textTertiary)
                    }

                    Text("当你深夜翻来覆去停不下来，打开夜屿，它陪你把堵在胸口的那件事理清楚，最后带走一张写着「今晚能做什么」的小卡片。")
                        .font(YeyuTypography.callout)
                        .foregroundStyle(YeyuColor.textSecondary)
                        .lineSpacing(6)

                    VStack(alignment: .leading, spacing: YeyuSpacing.md) {
                        principleRow(icon: "bubble.left", text: "深夜树洞，认真倾听")
                        principleRow(icon: "arrow.triangle.branch", text: "结构化情绪梳理，不是无边界倾诉")
                        principleRow(icon: "checkmark.circle", text: "可执行的微行动，而非空洞建议")
                        principleRow(icon: "heart", text: "不替代专业咨询，但真诚陪伴")
                    }

                    Divider().overlay(YeyuColor.borderDefault)

                    VStack(alignment: .leading, spacing: YeyuSpacing.sm) {
                        Text("危机支持热线")
                            .font(YeyuTypography.footnote.weight(.medium))
                            .foregroundStyle(YeyuColor.textTertiary)
                        Link("400-161-9995（24 小时）",
                             destination: URL(string: "tel:4001619995")!)
                            .font(YeyuTypography.footnote)
                            .foregroundStyle(YeyuColor.primary)
                    }

                    Text("本应用不提供医疗建议，不替代专业心理咨询或危机干预服务。")
                        .font(YeyuTypography.caption)
                        .foregroundStyle(YeyuColor.textTertiary)
                        .lineSpacing(4)
                }
                .padding(YeyuSpacing.xl)
            }
        }
        .navigationTitle("关于夜屿")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func principleRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: YeyuSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(YeyuColor.primary)
                .frame(width: 20)
            Text(text)
                .font(YeyuTypography.body)
                .foregroundStyle(YeyuColor.textSecondary)
                .lineSpacing(3)
        }
    }
}

#Preview {
    NavigationStack { AboutView() }
}
