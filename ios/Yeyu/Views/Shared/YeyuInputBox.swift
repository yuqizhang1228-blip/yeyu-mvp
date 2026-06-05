import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

/// 0515 玻璃输入框（Figma `414:2187` 对话 / `411:2006` 首页）。
/// - 内边距 12 · 圆角 24 · 文案/icon 行间距 19
/// - 左「+」：拍照 / 相册 → 本地 OCR 文字注入输入框
/// - 右：有文案 → 发送箭头；空态 → 语音 icon（本期未做，点按提示「即将上线」）
struct YeyuInputBox: View {
    @Binding var text: String
    var placeholder: String
    var focus: FocusState<Bool>.Binding
    var isLoading: Bool = false
    var submitLabel: SubmitLabel = .return
    var onSubmit: (() -> Void)? = nil
    var onSend: () -> Void

    @State private var showPlusMenu = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var photoItem: PhotosPickerItem?
    @State private var isRecognizing = false
    @State private var toastMessage: String?

    private var hasInput: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: YeyuSpacing.inputBoxRowGap) {
            textField
            iconRow
        }
        .padding(YeyuSpacing.md)
        .yeyuInputBoxGlass(cornerRadius: YeyuRadius.promptCard)
        // 整个胶囊（含内边距/行间距等死区）都作为聚焦热区，
        // 图标行的「+」与语音/发送按钮仍各自响应（Button 优先于此手势）。
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isLoading else { return }
            focus.wrappedValue = true
        }
        .overlay(alignment: .top) { toast }
        // 点击空白处收起「+」气泡
        .overlay {
            if showPlusMenu {
                Color.black.opacity(0.001)
                    .frame(width: 4000, height: 4000)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { showPlusMenu = false }
                    }
            }
        }
        // 「+」上方的深色玻璃气泡菜单
        .overlay(alignment: .topLeading) {
            if showPlusMenu {
                plusMenu
                    .alignmentGuide(VerticalAlignment.top) { $0[.bottom] + 8 }
                    .padding(.leading, 6)
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await handlePicked(image)
                }
                photoItem = nil
            }
        }
        #if canImport(UIKit)
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                Task { await handlePicked(image) }
            }
            .ignoresSafeArea()
        }
        #endif
    }

    private var textField: some View {
        Group {
            if let onSubmit {
                field.onSubmit(onSubmit)
            } else {
                field
            }
        }
    }

    private var field: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder).foregroundStyle(YeyuColor.textPlaceholder0515),
            axis: .vertical
        )
        .lineLimit(1...4)
        .font(YeyuTypography.body)
        .lineSpacing(YeyuTypography.bodyInputLineSpacing)
        .foregroundStyle(.white)
        .tint(YeyuColor.primary)
        .focused(focus)
        .submitLabel(submitLabel)
        .frame(minHeight: 22, alignment: .topLeading)
    }

    private var iconRow: some View {
        HStack(spacing: 0) {
            // 左：添加图片（拍照 / 相册）
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                    showPlusMenu.toggle()
                }
            } label: {
                YeyuInputModelIcon()
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .opacity(isLoading || isRecognizing ? 0.4 : 1)
            }
            .disabled(isLoading || isRecognizing)
            .accessibilityLabel("添加图片")
            .padding(.leading, -6.5)

            Spacer(minLength: YeyuSpacing.md)
            trailingAction
        }
    }

    @ViewBuilder
    private var trailingAction: some View {
        Button(action: trailingTap) {
            Group {
                if hasInput {
                    sendGlyph
                } else {
                    YeyuInputVoiceIcon()
                }
            }
            .frame(width: YeyuInputBoxIcon.size, height: YeyuInputBoxIcon.size)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .opacity(isLoading ? 0.4 : 1)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.18), value: hasInput)
        .accessibilityLabel(hasInput ? "发送" : "语音输入（即将上线）")
        .padding(.trailing, -6.5)
    }

    /// 有输入：白圆底 + 上箭头（与 `InputIconVoice` 圆底同色 #F9F9F9）
    private var sendGlyph: some View {
        ZStack {
            Circle()
                .fill(YeyuColor.iconVoiceBackground)
                .frame(width: YeyuInputBoxIcon.size, height: YeyuInputBoxIcon.size)
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(YeyuColor.iconVoiceGlyph)
        }
        .transition(.scale.combined(with: .opacity))
    }

    // 「+」上方的深色玻璃气泡：两行——拍照 / 从相册选择
    private var plusMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            plusMenuRow("拍照") { startCamera() }
            Rectangle().fill(Color.white.opacity(0.10)).frame(height: 0.5)
            plusMenuRow("从相册选择") { showPhotoPicker = true }
        }
        .padding(.vertical, 4)
        .padding(.bottom, 8) // 留给尾巴
        .frame(width: 150)
        .yeyuDarkGlass(in: DownTailBubble(tailInset: 22))
        .transition(.scale(scale: 0.9, anchor: .bottomLeading).combined(with: .opacity))
    }

    private func plusMenuRow(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) { showPlusMenu = false }
            action()
        } label: {
            Text(title)
                .font(YeyuTypography.body)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func startCamera() {
        #if canImport(UIKit)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showCamera = true
        } else {
            showToast("此设备不支持拍照")
        }
        #endif
    }

    @ViewBuilder
    private var toast: some View {
        if let toastMessage {
            Text(toastMessage)
                .font(YeyuTypography.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.82)))
                .offset(y: -46)
                .transition(.opacity)
        }
    }

    private func trailingTap() {
        if hasInput {
            onSend()
        } else {
            showToast("语音功能即将上线")
        }
    }

    @MainActor
    private func handlePicked(_ image: UIImage) async {
        isRecognizing = true
        showToast("正在识别文字…", autoHide: false)
        let recognized = await ImageTextRecognizer.recognize(in: image)
        isRecognizing = false
        let trimmed = recognized.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showToast("没有识别到文字")
            return
        }
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text = trimmed
        } else {
            text += "\n" + trimmed
        }
        focus.wrappedValue = true
        showToast("已添加图片中的文字")
    }

    private func showToast(_ message: String, autoHide: Bool = true) {
        withAnimation(.easeInOut(duration: 0.2)) { toastMessage = message }
        guard autoHide else { return }
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if toastMessage == message { toastMessage = nil }
                }
            }
        }
    }
}
