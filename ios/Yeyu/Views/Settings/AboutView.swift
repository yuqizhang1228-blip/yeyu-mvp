import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 关于夜屿（YUQ-38）— 大弹窗呈现，对齐 Figma 226:2844（月山 + 诞生记 + 创始人故事）。
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    /// 创始人故事（226:2866 原文）
    private let story: [String] = [
        "我是一名工作10年的UX设计师，一直在体系里满足别人的需求，感受过很多次职场的无奈和辛酸时刻。",
        "从2024年开始认真关注AI，在2026年感受到了一种巨大的动力——AI工具可以帮我写代码、调研、设计，我感觉时机已到。",
        "于是夜屿诞生了。我希望可以基于AI，为同样面对情绪困扰的人提供一些帮助。",
        "夜屿基于认知行为模型（CBT）构建，每次对话帮你找到那个关键念头，然后帮你梳理沉淀为一个可以立刻执行的行动，理清烦乱的思绪。",
        "“夜屿”这个名字，灵感源于夜间海上的小岛。岛是我们的港湾，是凌乱思绪的栖身之所。它并不是教条式地给你答案，而是陪伴你把模糊的思绪梳理成可执行的操作。",
        "希望它可以帮到你。",
    ]

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroMoon

                    Text("诞生记")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, YeyuSpacing.xxl)
                        .padding(.bottom, YeyuSpacing.lg)

                    VStack(alignment: .leading, spacing: YeyuSpacing.md) {
                        ForEach(story, id: \.self) { para in
                            Text(para)
                                .font(.system(size: 14))
                                .tracking(1)
                                .foregroundStyle(Color.white.opacity(0.8))
                                .lineSpacing(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Text("2026.05.01 22:13 于上海")
                            .font(.system(size: 14))
                            .tracking(1)
                            .foregroundStyle(Color.white.opacity(0.8))
                            .padding(.top, YeyuSpacing.md)
                    }
                    .padding(.horizontal, YeyuSpacing.xxl)
                    .padding(.bottom, YeyuSpacing.xxxl)
                }
            }
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
    }

    /// 月山 hero：取首屏插画的「月亮 + 山」区域，底部渐隐融入页面（无硬边卡片感，对齐 226:2857）。
    private var heroMoon: some View {
        let w = screenWidth
        let h = w * 874 / 402
        return Color.clear
            .frame(height: 320)
            .overlay(
                Image("HomeHeroBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .offset(y: h * 0.04)
            )
            .clipped()
            .mask(
                LinearGradient(
                    colors: [.black, .black, .clear],
                    startPoint: .top, endPoint: .bottom
                )
            )
    }

    private var screenWidth: CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.bounds.width
        #else
        return 393
        #endif
    }

    private var sheetHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Text("关于夜屿")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, 15)
    }

    private var sheetBg: some View {
        Color(hex: 0x161616, alpha: 0.96)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }
}

#Preview { AboutView() }
