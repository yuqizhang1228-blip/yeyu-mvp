import SwiftUI
import SwiftData

struct ChatView: View {
    static let networkErrorMessage = "网络有点问题，稍后再试试。"

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
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
    @State private var showChoiceGuide = false
    @State private var streamingText: String?

    private let api = ChatAPIClient()

    private var inputPlaceholder: String {
        savedCard != nil ? "还有什么想聊的…" : "说点什么…"
    }

    private var sheetCard: ParsedActionCard? {
        cardSheetReviewMode ? savedCard : pendingCard
    }

    var body: some View {
        ZStack(alignment: .leading) {
            YeyuColor.backgroundBase.ignoresSafeArea()

            VStack(spacing: 0) {
                chatHeader
                messageList
                if isLoading, streamingText == nil { typingIndicator }
                if showChoiceGuide {
                    ChoiceGuideView { option in
                        completeChoiceGuide()
                        Task { await sendUserMessage(option) }
                    }
                }
                if savedCard != nil {
                    CardBarView {
                        cardSheetReviewMode = true
                        showCardSheet = true
                    }
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
                    },
                    onDiscard: {
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
    }

    private var chatHeader: some View {
        HStack {
            Button { appState.drawerOpen = true } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Rectangle().frame(width: 20, height: 1.5)
                    Rectangle().frame(width: 14, height: 1.5)
                    Rectangle().frame(width: 20, height: 1.5)
                }
                .foregroundStyle(YeyuColor.textPrimary)
            }

            Spacer()

            if !sortedMessages.isEmpty {
                Text("\(userTurnCount) 轮")
                    .font(YeyuTypography.caption)
                    .foregroundStyle(YeyuColor.textTertiary)
            }

            Button {
                Task { await startNewChat() }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(YeyuColor.textPrimary)
                    .frame(width: 36, height: 36)
            }
            .disabled(isLoading)
            .accessibilityLabel("新建对话")
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.vertical, YeyuSpacing.sm)
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
                }
                .padding(.horizontal, YeyuSpacing.xl)
                .padding(.vertical, YeyuSpacing.lg)
            }
            .onChange(of: session?.messages.count ?? 0) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: streamingText) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: YeyuSpacing.sm) {
            ProgressView().tint(YeyuColor.primary)
            Text("夜屿正在思考...")
                .font(YeyuTypography.footnote)
                .foregroundStyle(YeyuColor.textTertiary)
            Spacer()
        }
        .padding(.horizontal, YeyuSpacing.xl)
        .padding(.bottom, YeyuSpacing.sm)
    }

    private var inputBar: some View {
        VStack(spacing: YeyuSpacing.xs) {
            HStack(spacing: YeyuSpacing.sm) {
                TextField(inputPlaceholder, text: $input, axis: .vertical)
                    .lineLimit(1...4)
                    .font(YeyuTypography.body)
                    .foregroundStyle(YeyuColor.textSecondary)
                    .padding(.horizontal, YeyuSpacing.lg)
                    .padding(.vertical, YeyuSpacing.md)

                Button {
                    let text = input
                    input = ""
                    if userTurnCount >= 1 {
                        completeChoiceGuide()
                    }
                    Task { await sendUserMessage(text) }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(YeyuColor.textInverse)
                        .frame(width: 39, height: 39)
                        .background(YeyuColor.primary)
                        .clipShape(Circle())
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .background(YeyuColor.backgroundInput)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(YeyuColor.borderDefault, lineWidth: 1))
            .padding(.horizontal, YeyuSpacing.xl)

            Text("本功能无法代替专业心理咨询")
                .font(YeyuTypography.caption)
                .foregroundStyle(YeyuColor.textTertiary)
                .padding(.bottom, YeyuSpacing.sm)
        }
        .padding(.top, YeyuSpacing.sm)
        .background(YeyuColor.backgroundBase)
        .overlay(alignment: .top) {
            Rectangle().fill(YeyuColor.borderDefault).frame(height: 1)
        }
    }

    private var sortedMessages: [ChatMessage] {
        (session?.messages ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    private var userTurnCount: Int {
        sortedMessages.filter { $0.messageRole == .user }.count
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
            evaluateChoiceGuideVisibility()
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
        appState.replaceChat()
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

        showChoiceGuide = false
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

            var reply = try await fetchAssistantReply(history: history, extra: extra)
            guard !reply.isEmpty else {
                throw ChatAPIError.emptyContent
            }

            if let parsed = CardParser.extract(from: reply) {
                reply = parsed.displayText.isEmpty ? "我帮你整理了一张卡片，要保存吗？" : parsed.displayText
                pendingCard = parsed.card
                cardSheetReviewMode = false
                showCardSheet = true
            }

            let aiMsg = ChatMessage(role: .assistant, content: reply)
            aiMsg.session = session
            session.messages.append(aiMsg)
            session.updatedAt = .now
            try? modelContext.save()

            evaluateChoiceGuideVisibility()
        } catch {
            let errMsg = ChatMessage(role: .assistant, content: Self.networkErrorMessage)
            errMsg.session = session
            session.messages.append(errMsg)
            try? modelContext.save()
            showChoiceGuide = false
        }
    }

    private func fetchAssistantReply(history: [ChatAPIClient.APIMessage], extra: [String]) async throws -> String {
        if api.prefersStreaming {
            do {
                var full = ""
                streamingText = ""
                for try await chunk in api.sendStream(
                    messages: history,
                    systemPrompt: SystemPrompt.production,
                    extraSystemMessages: extra
                ) {
                    full += chunk
                    streamingText = full
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

    private func evaluateChoiceGuideVisibility() {
        guard let session else {
            showChoiceGuide = false
            return
        }
        if session.choiceGuideCompleted || userTurnCount != 1 || pendingCard != nil || showCardSheet {
            showChoiceGuide = false
            return
        }
        let assistantCount = sortedMessages.filter { $0.messageRole == .assistant }.count
        showChoiceGuide = assistantCount == 1
    }

    private func completeChoiceGuide() {
        showChoiceGuide = false
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
        let memory = MemoryCard(
            sessionId: session.id,
            title: session.title,
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

#Preview {
    ChatView(sessionId: UUID(), initialMessage: nil)
        .environment(AppState())
}
