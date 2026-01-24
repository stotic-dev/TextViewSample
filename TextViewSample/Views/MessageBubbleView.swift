//
//  MessageBubbleView.swift
//  TextViewSample
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message

    private var isUser: Bool {
        message.sender == .user
    }

    var body: some View {
        HStack {
            if isUser {
                Spacer()
            }

            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isUser ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 12) {
        MessageBubbleView(
            message: Message(content: "Hello!", sender: .user)
        )
        MessageBubbleView(
            message: Message(content: "Hi! How can I help you today?", sender: .assistant)
        )
    }
}
