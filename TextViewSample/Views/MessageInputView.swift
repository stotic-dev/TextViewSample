//
//  MessageInputView.swift
//  TextViewSample
//

import SwiftUI

struct MessageInputView: View {
    @State var text = ""
    @FocusState private var isFocused: Bool
    let onSend: (_ message: String) -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3)
                .focused($isFocused)
            Button{
                let text = self.text
                self.text = ""
                onSend(text)
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
}

#Preview {
    MessageInputView {
        print("Send: \($0)")
    }
}
