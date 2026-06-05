import SwiftUI

/// 首页快捷聊天卡的骨架加载态：两排浅灰条 + 左右波动的微光（shimmer）。
/// 尺寸与真实卡片一致（168×42 内容 + 16 内边距 = 200×74）。
struct PromptCardSkeleton: View {
    @State private var phase: CGFloat = -1

    private var bars: some View {
        VStack(alignment: .leading, spacing: 10) {
            Capsule().frame(width: 140, height: 12)
            Capsule().frame(width: 92, height: 12)
        }
        .frame(width: 168, height: 42, alignment: .topLeading)
    }

    var body: some View {
        bars
            .foregroundStyle(Color.white.opacity(0.14))
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.35), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width)
                    .offset(x: phase * geo.size.width)
                }
                .mask(bars) // 微光只落在灰条上
            }
            .padding(YeyuSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                    .fill(YeyuColor.surfacePromptCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: YeyuRadius.promptCard)
                            .stroke(YeyuColor.borderPromptCard, lineWidth: 1)
                    )
            )
            .onAppear {
                phase = -1
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    phase = 1
                }
            }
            .accessibilityLabel("正在加载")
    }
}
