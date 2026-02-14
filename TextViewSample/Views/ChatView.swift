//
//  ChatView.swift
//  TextViewSample
//

import SwiftUI

struct ChatView: View {
    @Environment(\.chatRepository) private var chatRepository
    @State private var messages: [Message] = []
    @State private var isLoading = false
    @State private var isShowingKeyboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MessageListView(messages: messages, isShowingKeyboard: $isShowingKeyboard)
                MessageInputView(isShowingKeyboard: $isShowingKeyboard, onSend: sendMessage)
            }
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: clearMessages) {
                        Image(systemName: "trash")
                    }
                    .disabled(messages.isEmpty)
                }
            }
        }
    }

    private func sendMessage(_ message: String) {
        let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = Message(content: text, sender: .user)
        messages.append(userMessage)

        Task {
            await generateResponse(for: text)
        }
    }

    private func generateResponse(for userMessage: String) async {
        guard chatRepository.isAvailable() else {
            let errorMessage = Message(
                content: "Foundation Models is not available on this device.",
                sender: .assistant
            )
            messages.append(errorMessage)
            return
        }

        isLoading = true
        defer { isLoading = false }

        let assistantMessageId = UUID()
        var assistantMessage = Message(
            id: assistantMessageId,
            content: "",
            sender: .assistant
        )
        messages.append(assistantMessage)

        do {
            let stream = try await chatRepository.sendMessage(userMessage, messages)
            for try await chunk in stream {
                if let index = messages.firstIndex(where: { $0.id == assistantMessageId }) {
                    messages[index] = Message(
                        id: assistantMessageId,
                        content: chunk,
                        sender: .assistant,
                        timestamp: assistantMessage.timestamp
                    )
                }
            }
        } catch {
            if let index = messages.firstIndex(where: { $0.id == assistantMessageId }) {
                messages[index] = Message(
                    id: assistantMessageId,
                    content: "An error occurred: \(error.localizedDescription)",
                    sender: .assistant,
                    timestamp: assistantMessage.timestamp
                )
            }
        }
    }

    private func clearMessages() {
        messages.removeAll()
        chatRepository.clearHistory()
    }
}

#Preview {
    ChatView()
        .environment(\.chatRepository, .mock)
}
