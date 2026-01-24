//
//  Message.swift
//  TextViewSample
//

import Foundation

struct Message: Identifiable, Equatable {
    let id: UUID
    let content: String
    let sender: Sender
    let timestamp: Date

    enum Sender: Equatable {
        case user
        case assistant
    }

    init(
        id: UUID = UUID(),
        content: String,
        sender: Sender,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.sender = sender
        self.timestamp = timestamp
    }
}
