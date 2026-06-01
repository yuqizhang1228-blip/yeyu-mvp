import SwiftUI

/// 空壳首页 — 验证脚手架可编译运行
/// 完整首页 UI 见 YUQ-27（HomeView），聊天页见 YUQ-32（ChatView）
struct ContentView: View {
    var body: some View {
        ZStack {
            // 深色背景
            Color.YY.background
                .ignoresSafeArea()

            // 背景光晕（Orb 装饰）
            backgroundOrbs

            VStack(spacing: 0) {
                // 顶栏
                TopBarWithTrailingContent(title: "夜屿") {
                    HStack(spacing: 0) {
                        IconButton(
                            systemName: "clock.arrow.circlepath",
                            accessibilityLabel: "历史对话"
                        ) {
                            // TODO: 打开历史列表（YUQ-30）
                        }
                    }
                }

                Spacer()

                // 中心内容区
                VStack(spacing: Yeyu.Spacing.xxl) {
                    // 品牌标题
                    VStack(spacing: Yeyu.Spacing.sm) {
                        Text("夜屿")
                            .font(Yeyu.Typography.display)
                            .foregroundColor(Color.YY.textPrimary)
                        Text("Night Isle")
                            .font(Yeyu.Typography.caption)
                            .foregroundColor(Color.YY.textSecondary)
                            .kerning(2)
                    }

                    // 副标题
                    Text("把堵在胸口的那件事\n慢慢理清楚")
                        .font(Yeyu.Typography.body)
                        .foregroundColor(Color.YY.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(Yeyu.Typography.bodyLineSpacing)
                }

                Spacer()

                // 底部 CTA
                VStack(spacing: Yeyu.Spacing.md) {
                    PrimaryButton(title: "开始今晚的对话", icon: "moon.stars") {
                        // TODO: 进入 ChatView（YUQ-32）
                    }
                    .padding(.horizontal, Yeyu.Spacing.xl)

                    SecondaryButton(title: "查看卡片记录") {
                        // TODO: 进入卡片列表（YUQ-40）
                    }
                    .padding(.horizontal, Yeyu.Spacing.xl)

                    // 版本标记
                    Text("iOS v1 · 脚手架")
                        .font(Yeyu.Typography.label)
                        .foregroundColor(Color.YY.textSubtle)
                        .padding(.top, Yeyu.Spacing.sm)
                }
                .padding(.bottom, Yeyu.Spacing.xxxl)
            }
        }
    }

    // MARK: - Background Orbs

    private var backgroundOrbs: some View {
        ZStack {
            // 主光球（橙色）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.YY.glowPrimary.opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 80, y: -200)
                .blur(radius: Yeyu.Blur.strong)

            // 次光球（靛蓝）
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.YY.indigo.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .offset(x: -100, y: 200)
                .blur(radius: Yeyu.Blur.base)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    ContentView()
}
