//
//  MessageListView.swift
//  TextViewSample
//

import SwiftUI

struct MessageListView: View {
    let messages: [Message]
    @State private var isNearBottom = true
    @State private var shouldScrollAfterKeyboard = false
    @Binding var isShowingKeyboard: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                    Color.clear
                        .frame(height: 1)
                        .onAppear { isNearBottom = true }
                        .onDisappear { isNearBottom = false }
                }
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .top)
                }
            }
            .onChange(of: messages.count) {
                scrollToLastMessage(using: proxy)
            }
            .onChange(of: isShowingKeyboard) {
                guard isShowingKeyboard else { return }
                Task {
                    try await Task.sleep(for: .milliseconds(100))
                    if isNearBottom {
                        scrollToLastMessage(using: proxy)
                    }
                }
            }
        }
    }

    private func scrollToLastMessage(using proxy: ScrollViewProxy) {
        guard let lastMessage = messages.last else { return }
        withAnimation {
            proxy.scrollTo(lastMessage.id, anchor: .top)
        }
    }
}

#Preview {
    MessageListView(
        messages: [
            Message(content: "Hello!", sender: .user),
            Message(content: "Hi! How can I help you today?", sender: .assistant),
            Message(content: "What is Swift?", sender: .user),
            Message(content: "Swift is a powerful programming language developed by Apple.", sender: .assistant)
        ],
        isShowingKeyboard: .constant(false)
    )
}
