import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ChatView: View {
    static let networkErrorMessage = "网络有点问题，稍后再试试。"

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @AppStorage(YeyuUser.usernameKey) private var username = ""

    let sessionId: UUID
    let initialMessage: String?

    @State private var session: ChatSession?
    @State private var input = ""
    @State private var isLoading = false
    @State private var pendingCard: ParsedActionCard?
    @State private var savedCard: ParsedActionCard?
    @State private var showCardSheet = false
    @State private var cardSheetReviewMode = false
    @State private var initialSent = false
    /// AI 输出 <choices> 标签时解析到此，驱动 ChoiceGuideView 显示
    @State private var pendingChoices: [String]? = nil
    @State private var streamingText: String?
    @FocusState private var inputFocused: Bool

    private let api = ChatAPIClient()

    private var inputPlaceholder: String {
        savedCard != nil ? "还有什么想聊的…" : "随便聊聊..."
    }

    private var sheetCard: ParsedActionCard? {
        cardSheetReviewMode ? savedCard : pendingCard
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // 对话页底：与首页同族的克制深色（0515），避免大面积纯蓝黑。
            LinearGradient(
                colors: [YeyuColor.background0515Top, YeyuColor.backgroundDrawer],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                chatHeader
                messageList
                // AI 驱动的引导选项（YUQ-52）
                if let choices = pendingChoices {
                    ChoiceGuideView(options: choices) { option in
                        pendingChoices = nil
                        Task { await sendUserMessage(option) }
                    }
                }
                if savedCard != nil {
                    CardBarView {
                        cardSheetReviewMode = true
                        showCardSheet = true
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                inputBar
            }

            SideDrawerView(currentSessionId: sessionId)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: Binding(
            get: { appState.showCrisisSheet },
            set: { appState.showCrisisSheet = $0 }
        )) {
            CrisisSheetView()
        }
        .sheet(isPresented: $showCardSheet, onDismiss: { cardSheetReviewMode = false }) {
            if let card = sheetCard {
                ActionCardSheet(
                    card: card,
                    isReviewMode: cardSheetReviewMode,
                    onSave: { savePendingCard() },
                    onContinue: {
                        pendingCard = nil
                        cardSheetReviewMode = false
                    }
                )
            }
        }
        .task {
            loadOrCreateSession()
            if let initialMessage, !initialSent, sortedMessages.isEmpty {
                initialSent = true
                await sendUserMessage(initialMessage)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // 退后台也沉淀一次（用户不一定点「新对话」），按会话节流避免重复
            if phase == .background { triggerMemoryExtraction() }
        }
    }

    /// 顶栏 — Figma `226:2479` Nav bar：左 Menu 24 + 右 icon/add 24，无居中文案。
    private var chatHeader: some View {
        HStack {
            Button {
                // 离开会话：归档（生成标题 + 沉淀记忆）后返回上一页
                Task { await archiveCurrentSessionIfNeeded() }
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(YeyuColor.textPrimary)
                    .frame(width: 44, height: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("返回")

            Spacer()

            Button {
                Task { await startNewChat() }
            } label: {
                YeyuNavAddIcon()
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.4 : 1)
            .accessibilityLabel("新建对话")
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, YeyuNavBarIcon.barVerticalPadding)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: YeyuSpacing.lg) {
                    ForEach(sortedMessages, id: \.id) { msg in
                        ChatBubbleView(
                            role: msg.messageRole,
                            content: msg.content,
                            onRetry: shouldOfferRetry(for: msg)
                                ? { Task { await retryAfterNetworkError() } }
                                : nil
                        )
                        .id(msg.id)
                    }
                    if let streamingText {
                        ChatBubbleView(role: .assistant, content: streamingText)
                            .id("streaming")
                    }
                    // AI 思考步骤条（YUQ-35 · 226:2516/2568/2621）— 等待响应时的客户端动画
                    if isLoading, streamingText == nil {
                        ThinkingIndicator()
                            .id("thinking")
                    }
                }
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.vertical, YeyuSpacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: session?.messages.count ?? 0) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: streamingText) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isLoading) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private var hasInput: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 对话输入框 — Figma `414:2187` input box
    private var inputBar: some View {
        VStack(spacing: YeyuSpacing.md) {
            YeyuInputBox(
                text: $input,
                placeholder: inputPlaceholder,
                focus: $inputFocused,
                isLoading: isLoading,
                submitLabel: .return,
                onSend: sendCurrentInput
            )
            .padding(.horizontal, YeyuSpacing.xl)

            Text("本功能无法代替专业心理咨询或医学治疗")
                .font(YeyuTypography.caption)
                .foregroundStyle(YeyuColor.textCompliance)
                .padding(.bottom, YeyuSpacing.sm)
        }
        .padding(.top, YeyuSpacing.sm)
    }

    private func sendCurrentInput() {
        guard hasInput, !isLoading else { return }
        let text = input
        input = ""
        pendingChoices = nil
        inputFocused = false
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        Task { await sendUserMessage(text) }
    }

    private var sortedMessages: [ChatMessage] {
        (session?.messages ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    private var messagesForAPI: [ChatMessage] {
        sortedMessages.filter {
            !($0.messageRole == .assistant && $0.content == Self.networkErrorMessage)
        }
    }

    private func loadOrCreateSession() {
        let descriptor = FetchDescriptor<ChatSession>(predicate: #Predicate { $0.id == sessionId })
        if let existing = try? modelContext.fetch(descriptor).first {
            session = existing
            restoreSavedCardIfAny()
            return
        }
        let newSession = ChatSession(id: sessionId)
        modelContext.insert(newSession)
        session = newSession
        try? modelContext.save()
    }

    private func restoreSavedCardIfAny() {
        let sid = sessionId
        var cardDescriptor = FetchDescriptor<MemoryCard>(
            predicate: #Predicate { $0.sessionId == sid },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        cardDescriptor.fetchLimit = 1
        guard let memory = try? modelContext.fetch(cardDescriptor).first else { return }
        savedCard = ParsedActionCard(
            thought: memory.thought,
            reframe: memory.reframe,
            actions: memory.actions
        )
    }

    private func startNewChat() async {
        guard !isLoading else { return }
        await archiveCurrentSessionIfNeeded()
        appState.goHome()
    }

    private func archiveCurrentSessionIfNeeded() async {
        guard let session else { return }
        let hasUser = sortedMessages.contains { $0.messageRole == .user }
        let hasAssistant = sortedMessages.contains { $0.messageRole == .assistant }
        guard hasUser && hasAssistant else { return }

        if let title = await HistoryTitleService.generateTitle(for: messagesForAPI) {
            session.title = title
        } else if session.title == "新对话" {
            session.title = "一次未完成的对话"
        }
        session.updatedAt = .now
        try? modelContext.save()

        triggerMemoryExtraction()
    }

    /// 对话沉淀记忆（YUQ-39 闭环）。归档时 + 退后台时调用；服务内按会话节流、受开关控制。
    /// 主线程拼纯文本，再交后台抽取，避免传递非 Sendable 的 SwiftData 模型。
    private func triggerMemoryExtraction() {
        guard MemoryStore.autoEnabled, let session else { return }
        let msgs = messagesForAPI
        guard msgs.contains(where: { $0.messageRole == .user }),
              msgs.contains(where: { $0.messageRole == .assistant }) else { return }
        let sid = session.id
        guard !MemoryStore.hasExtracted(sid) else { return }
        let transcript = msgs
            .map { ($0.messageRole == .user ? "用户" : "AI") + "：" + $0.content }
            .joined(separator: "\n")
        Task { await MemoryExtractionService.extractAndStore(sessionId: sid, fromTranscript: transcript) }
    }

    private func sendUserMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let session else { return }

        if CrisisGuard.shouldShowCrisisUI(for: trimmed) {
            appState.showCrisisSheet = true
        }

        let userMsg = ChatMessage(role: .user, content: trimmed)
        userMsg.session = session
        session.messages.append(userMsg)
        session.updatedAt = .now
        if session.title == "新对话" {
            session.title = String(trimmed.prefix(24))
        }
        try? modelContext.save()

        pendingChoices = nil
        await requestAssistantReply()
    }

    private func retryAfterNetworkError() async {
        guard let last = sortedMessages.last,
              last.messageRole == .assistant,
              last.content == Self.networkErrorMessage else { return }
        modelContext.delete(last)
        try? modelContext.save()
        await requestAssistantReply()
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            if streamingText != nil {
                proxy.scrollTo("streaming", anchor: .bottom)
            } else if isLoading {
                proxy.scrollTo("thinking", anchor: .bottom)
            } else if let last = sortedMessages.last?.id {
                proxy.scrollTo(last, anchor: .bottom)
            }
        }
    }

    private func requestAssistantReply() async {
        guard let session else { return }

        isLoading = true
        streamingText = nil
        defer {
            isLoading = false
            streamingText = nil
        }

        do {
            let history = messagesForAPI.map {
                ChatAPIClient.APIMessage(
                    role: $0.messageRole == .user ? "user" : "assistant",
                    content: $0.content
                )
            }
            let timeCtx = TimeContext.current()
            var extra: [String] = [timeCtx.systemLine]
            if let nameLine = YeyuUser.systemNameLine(stored: username) {
                extra.append(nameLine)
            }
            // 注入长期记忆（控量 top-8），让对话「记得你」（YUQ-39 P1）
            if let memLine = MemoryStore.chatSystemLine() {
                extra.append(memLine)
            }

            var reply = try await fetchAssistantReply(history: history, extra: extra)
            guard !reply.isEmpty else {
                throw ChatAPIError.emptyContent
            }

            // AI 引导选项（YUQ-52）：先解析 choices，再解析卡片
            if let choices = ChoicesParser.extract(from: reply) {
                reply = ChoicesParser.strip(from: reply)
                pendingChoices = choices
            }

            if let parsed = CardParser.extract(from: reply) {
                reply = parsed.displayText.isEmpty ? "我帮你整理了一张卡片，要保存吗？" : parsed.displayText
                pendingCard = parsed.card
                cardSheetReviewMode = false
                showCardSheet = true
                pendingChoices = nil  // 出卡时清除选项
            }

            // AI 回吐信息时振动一次（YUQ-32 #6）
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            #endif

            // 打字机效果（YUQ-32 #7 客户端版）：非真流式路径下，逐字展现已清洗文案。
            // 真后端 SSE 就绪后由 fetchAssistantReply 直接流式（YUQ-47），此处自动跳过。
            if streamingText == nil {
                await revealTypewriter(reply)
            }

            let aiMsg = ChatMessage(role: .assistant, content: reply)
            aiMsg.session = session
            session.messages.append(aiMsg)
            session.updatedAt = .now
            try? modelContext.save()
        } catch {
            let errMsg = ChatMessage(role: .assistant, content: Self.networkErrorMessage)
            errMsg.session = session
            session.messages.append(errMsg)
            try? modelContext.save()
            pendingChoices = nil
        }
    }

    /// 客户端逐字展现（打字机）。总时长受控（长文不至于太慢）；减弱动效时直接整段呈现。
    private func revealTypewriter(_ text: String) async {
        guard !reduceMotion else { return }
        let chars = Array(text)
        guard !chars.isEmpty else { return }
        let total = chars.count
        let steps = min(total, 70)
        let perStep = max(1, total / steps)
        var shown = 0
        streamingText = ""
        while shown < total {
            shown = min(total, shown + perStep)
            streamingText = String(chars[0..<shown])
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: 18_000_000)
        }
    }

    private func fetchAssistantReply(history: [ChatAPIClient.APIMessage], extra: [String]) async throws -> String {
        if api.prefersStreaming {
            do {
                var full = ""
                // 不预置空串：保持思考条直到第一个 token 到达，避免空白间隙
                for try await chunk in api.sendStream(
                    messages: history,
                    systemPrompt: SystemPrompt.production,
                    extraSystemMessages: extra
                ) {
                    full += chunk
                    streamingText = Self.streamDisplay(full)
                }
                return full
            } catch {
                streamingText = nil
                // 线上若尚未部署 stream，回退整包响应
                return try await api.send(
                    messages: history,
                    systemPrompt: SystemPrompt.production,
                    extraSystemMessages: extra
                )
            }
        }
        return try await api.send(
            messages: history,
            systemPrompt: SystemPrompt.production,
            extraSystemMessages: extra
        )
    }

    /// 流式展示时隐藏协议标签（`<choices>` / `<card>` 都在回复末尾），避免标签闪现；
    /// 返回的原始 `full` 仍含标签，供解析。
    private static func streamDisplay(_ raw: String) -> String {
        var s = raw
        for marker in ["<choices", "<card"] {
            if let r = s.range(of: marker, options: .caseInsensitive) {
                s = String(s[..<r.lowerBound])
            }
        }
        return s
    }

    private func completeChoiceGuide() {
        pendingChoices = nil
        guard let session, !session.choiceGuideCompleted else { return }
        session.choiceGuideCompleted = true
        try? modelContext.save()
    }

    private func shouldOfferRetry(for message: ChatMessage) -> Bool {
        message.messageRole == .assistant
            && message.content == Self.networkErrorMessage
            && message.id == sortedMessages.last?.id
            && !isLoading
    }

    private func savePendingCard() {
        guard let card = pendingCard, let session else { return }
        let actionsPayload: String
        if let data = try? JSONEncoder().encode(card.actionItems),
           let json = String(data: data, encoding: .utf8), !card.actionItems.isEmpty {
            actionsPayload = json
        } else {
            actionsPayload = card.actions
        }
        // title 取 thought 前 20 字，避免 AI 异步标题未落库时出现「新对话」占位
        let cardTitle = String(card.thought.prefix(20))
        let memory = MemoryCard(
            sessionId: session.id,
            title: cardTitle.isEmpty ? "行动卡片" : cardTitle,
            thought: card.thought,
            reframe: card.reframe,
            actions: actionsPayload
        )
        modelContext.insert(memory)
        try? modelContext.save()
        savedCard = card
        pendingCard = nil
        UserProfileService.recordCardTopic(thought: card.thought)
    }
}

/// AI 思考步骤条（YUQ-35 · 226:2516/2568/2621）
/// 等待响应时的纯客户端动画：山形 icon + 三步文案渐变切换 + 文字微光扫过。
/// 不依赖后端 SSE；真流式打字机归 YUQ-47。
private struct ThinkingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let steps = ["AI 正在理解问题...", "AI 正在梳理思绪...", "AI 正在整理表达..."]
    @State private var step = 0
    @State private var shimmerX: CGFloat = -120

    var body: some View {
        HStack(spacing: YeyuSpacing.sm) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.8))

            label
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task { await cycleSteps() }
        .onAppear { startShimmer() }
    }

    private var label: some View {
        let text = steps[step]
        return Text(text)
            .font(.system(size: 12))
            .tracking(0.96)
            .foregroundStyle(Color.white.opacity(reduceMotion ? 0.8 : 0.45))
            .overlay {
                if !reduceMotion {
                    Text(text)
                        .font(.system(size: 12))
                        .tracking(0.96)
                        .foregroundStyle(.white)
                        .mask(
                            LinearGradient(
                                colors: [.clear, .white, .clear],
                                startPoint: .leading, endPoint: .trailing
                            )
                            .frame(width: 64)
                            .offset(x: shimmerX)
                        )
                }
            }
            .id(step)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.45), value: step)
    }

    private func startShimmer() {
        guard !reduceMotion else { return }
        shimmerX = -120
        withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: false)) {
            shimmerX = 140
        }
    }

    private func cycleSteps() async {
        guard !reduceMotion else { return }
        while step < steps.count - 1 {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            if Task.isCancelled { return }
            withAnimation(.easeInOut(duration: 0.45)) { step = min(step + 1, steps.count - 1) }
        }
    }
}

#Preview {
    ChatView(sessionId: UUID(), initialMessage: nil)
        .environment(AppState())
}
