import SwiftUI

/// 个性化（YUQ-37）— 大弹窗呈现，对齐 Figma 226:2802（分组卡：记忆 / 偏好自定义）。
struct PersonalizationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("yeyu_auto_memory") private var autoMemory = true
    @State private var showMemoryManagement = false
    @State private var showStyleToast = false

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    sectionLabel("记忆")
                    groupCard {
                        toggleRow(label: "参考保存记忆", isOn: $autoMemory)
                        rowDivider
                        navRow(label: "编辑你的记忆") { showMemoryManagement = true }
                    }
                    .padding(.horizontal, YeyuSpacing.xl)

                    sectionLabel("偏好自定义")
                    groupCard {
                        // 沟通风格自定义为 v1.1，占位提示
                        navRow(label: "你希望 AI 有怎样的沟通风格") { showStyleToast = true }
                    }
                    .padding(.horizontal, YeyuSpacing.xl)
                }
                .padding(.bottom, YeyuSpacing.xxl)
            }
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .overlay(alignment: .bottom) {
            if showStyleToast { comingSoonToast }
        }
        .animation(.easeInOut(duration: 0.2), value: showStyleToast)
        .sensoryFeedback(.impact(weight: .light), trigger: showStyleToast)
        .sheet(isPresented: $showMemoryManagement) { MemoryManagementView() }
    }

    // MARK: 分组卡

    private func groupCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: YeyuRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: YeyuRadius.xl)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }

    private func toggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(YeyuColor.primary)
                .labelsHidden()
        }
        .padding(.horizontal, YeyuSpacing.lg)
        .frame(height: 52)
    }

    private func navRow(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.3))
            }
            .padding(.horizontal, YeyuSpacing.lg)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .padding(.leading, YeyuSpacing.lg)
    }

    private var comingSoonToast: some View {
        Text("敬请期待")
            .font(YeyuTypography.footnote)
            .foregroundStyle(.white)
            .padding(.horizontal, YeyuSpacing.lg)
            .padding(.vertical, YeyuSpacing.sm + 2)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 48)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .task(id: showStyleToast) {
                guard showStyleToast else { return }
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                showStyleToast = false
            }
    }

    // MARK: 通用

    private var sheetHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Text("个性化")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, 15)
    }

    private var sheetBg: some View {
        Color(hex: 0x161616, alpha: 0.92)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundStyle(Color.white.opacity(0.3))
            .padding(.horizontal, YeyuSpacing.xl)
            .padding(.top, YeyuSpacing.xl)
            .padding(.bottom, YeyuSpacing.sm)
    }
}

#Preview { PersonalizationView() }

/// 记忆管理（YUQ-39）— 对齐 Figma 226:2868：记忆列表 + 左滑删除 + 清空（二次确认）。
/// 「用户可以自定义」：右上「+」手动添加；自动沉淀见 `MemoryExtractionService`。
struct MemoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var memories: [MemoryEntry] = []
    @State private var showClearConfirm = false
    @State private var showEditor = false
    @State private var editing: MemoryEntry?

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(sheetBg)
        .presentationDetents([.large])
        .presentationCornerRadius(24)
        .presentationDragIndicator(.visible)
        .onAppear { memories = MemoryStore.all() }
        .confirmationDialog("确认清空所有记忆？\n清空后无法恢复。", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("清空", role: .destructive) {
                MemoryStore.clear()
                memories = []
            }
            Button("取消", role: .cancel) {}
        }
        .sheet(isPresented: $showEditor) {
            MemoryEditorView(original: editing) { text in
                if let editing {
                    MemoryStore.update(id: editing.id, text: text)
                } else {
                    MemoryStore.add(text, source: "manual")
                }
                memories = MemoryStore.all()
            }
        }
    }

    private func openAdd() {
        editing = nil
        showEditor = true
    }

    private func openEdit(_ entry: MemoryEntry) {
        editing = entry
        showEditor = true
    }

    @ViewBuilder
    private var content: some View {
        if memories.isEmpty {
            Spacer()
            VStack(spacing: YeyuSpacing.sm) {
                Text("还没有记忆")
                    .font(YeyuTypography.body)
                    .foregroundStyle(YeyuColor.textTertiary)
                Text("开启「参考保存记忆」后，夜屿会从对话里慢慢记住关于你的事。")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, YeyuSpacing.xxl)
            }
            Spacer()
        } else {
            // 列表行对齐 226:2868：正文 14pt 白（行高 1.6），底部 1px 白 10% 分割线（内缩 20）
            List {
                ForEach(memories) { item in
                    VStack(spacing: 0) {
                        Text(item.text)
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, YeyuSpacing.xl)
                            .padding(.vertical, YeyuSpacing.lg)
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, YeyuSpacing.xl)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture { openEdit(item) }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            MemoryStore.delete(item.id)
                            memories = MemoryStore.all()
                        } label: { Label("删除", systemImage: "trash") }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var header: some View {
        ZStack {
            Text("记忆管理")
                .font(.system(size: 18))
                .foregroundStyle(.white)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                Spacer()
                Button { openAdd() } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("新增记忆")
                Button("清空") { showClearConfirm = true }
                    .font(.system(size: 15))
                    .foregroundStyle(memories.isEmpty ? YeyuColor.textTertiary : YeyuColor.error)
                    .disabled(memories.isEmpty)
            }
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .frame(height: 50)
    }

    private var sheetBg: some View {
        Color(hex: 0x161616, alpha: 0.92)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .ignoresSafeArea()
    }
}
