import SwiftUI

/// 界面语言（YUQ-34）— 大弹窗呈现，v1 仅简体中文
struct LanguageView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            VStack(alignment: .leading, spacing: 0) {
                // 选项列表对齐设计稿 226:2269（中文–简 / 中文–繁 / English）；
                // v1 仅简体可用，其余诚实置为「即将推出」，不做非功能切换。
                languageRow(name: "中文–简", isSelected: true, available: true)
                rowDivider
                languageRow(name: "中文–繁", isSelected: false, available: false)
                rowDivider
                languageRow(name: "English", isSelected: false, available: false)
            }
            .padding(.top, YeyuSpacing.md)
            Text("v1 仅支持简体中文，多语言将在后续版本开放。")
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.3))
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.top, YeyuSpacing.lg)
            Spacer()
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
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
            Text("界面语言")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, 15)
    }

    private var rowDivider: some View {
        Divider().background(Color.white.opacity(0.05)).padding(.horizontal, YeyuSpacing.xl)
    }

    private var sheetBg: some View {
        Color(hex: 0x161616, alpha: 0.92)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }

    private func languageRow(name: String, isSelected: Bool, available: Bool) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 16))
                .foregroundStyle(available ? .white : Color.white.opacity(0.3))
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(YeyuColor.primary)
            } else if !available {
                Text("即将推出")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.3))
            }
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, YeyuSpacing.lg)
    }
}

#Preview { LanguageView() }
