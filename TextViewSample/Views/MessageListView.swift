//
//  MessageListView.swift
//  TextViewSample
//

import SwiftUI

struct MessageListView: View {
    let messages: [Message]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: messages.count) {
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

#Preview {
    MessageListView(messages: [
        Message(content: "Hello!", sender: .user),
        Message(content: "Hi! How can I help you today?", sender: .assistant),
        Message(content: "What is Swift?", sender: .user),
        Message(content: "Swift is a powerful programming language developed by Apple.", sender: .assistant)
    ])
}
