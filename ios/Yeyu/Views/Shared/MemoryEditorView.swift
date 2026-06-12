import SwiftUI

/// 记忆新增 / 编辑小弹窗（YUQ-37「编辑你的记忆」）。
/// `original == nil` 为新增（写入 source=manual）；否则为编辑现有条目。
struct MemoryEditorView: View {
    let original: MemoryEntry?
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @FocusState private var focused: Bool

    init(original: MemoryEntry?, onSave: @escaping (String) -> Void) {
        self.original = original
        self.onSave = onSave
        _text = State(initialValue: original?.text ?? "")
    }

    private var canSave: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            TextField("写下一条想让夜屿记住的事…", text: $text, axis: .vertical)
                .lineLimit(3...8)
                .font(.system(size: 16))
                .lineSpacing(4)
                .foregroundStyle(.white)
                .tint(YeyuColor.primary)
                .focused($focused)
                .padding(YeyuSpacing.lg)
                .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: YeyuRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: YeyuRadius.lg)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.top, YeyuSpacing.sm)
            Spacer(minLength: 0)
        }
        .background(sheetBg)
        .presentationDetents([.height(260)])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .onAppear { focused = true }
    }

    private var header: some View {
        ZStack {
            Text(original == nil ? "新增记忆" : "编辑记忆")
                .font(.system(size: 16))
                .foregroundStyle(.white)
            HStack {
                Button("取消") { dismiss() }
                    .foregroundStyle(Color.white.opacity(0.6))
                Spacer()
                Button("保存") {
                    onSave(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                }
                .foregroundStyle(canSave ? YeyuColor.primary : YeyuColor.textTertiary)
                .disabled(!canSave)
            }
            .font(.system(size: 15))
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .frame(height: 52)
    }

    private var sheetBg: some View {
        Color(hex: 0x161616, alpha: 0.92)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }
}
