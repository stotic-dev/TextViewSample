//
//  MessageInputView.swift
//  TextViewSample
//

import SwiftUI

struct MessageInputView: View {
    @State private var text = ""
    
    @Binding var isShowingKeyboard: Bool
    let onSend: (_ message: String) -> Void

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack {
                if text.isEmpty {
                    Text("Message")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                GrowingTextView(text: $text, isShowingKeyboard: $isShowingKeyboard, maxLineCount: 3)
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.4))
            }
            Button {
                let message = text
                text = ""
                onSend(message)
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(canSend ? Color.blue : Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!canSend)
        }
        .padding()
    }
}

#Preview {
    MessageInputView(isShowingKeyboard: .constant(false)) {
        print("Send: \($0)")
    }
}
