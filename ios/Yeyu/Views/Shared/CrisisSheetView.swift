import SwiftUI

struct CrisisSheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: YeyuSpacing.xl) {
                Text("你并不孤单")
                    .font(YeyuTypography.title)
                    .foregroundStyle(YeyuColor.textTitle)

                Text("如果你正在经历危机，请立即联系专业人士。")
                    .font(YeyuTypography.body)
                    .foregroundStyle(YeyuColor.textSecondary)

                Link(destination: URL(string: "tel://\(CrisisGuard.hotline)")!) {
                    Text("拨打 \(CrisisGuard.hotline)")
                        .font(YeyuTypography.callout.weight(.semibold))
                        .foregroundStyle(YeyuColor.textInverse)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, YeyuSpacing.lg)
                        .background(YeyuColor.primary)
                        .clipShape(RoundedRectangle(cornerRadius: YeyuRadius.lg))
                }

                Text("夜屿不能替代心理咨询或医疗诊断。")
                    .font(YeyuTypography.footnote)
                    .foregroundStyle(YeyuColor.textTertiary)

                Spacer()
            }
            .padding(YeyuSpacing.xl)
            .background(YeyuColor.backgroundBase)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(YeyuColor.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    CrisisSheetView()
}
