//
//  ChatRepository.swift
//  TextViewSample
//

import Foundation
import FoundationModels
import SwiftUI

struct ChatRepository: Sendable {
    var isAvailable: @Sendable () -> Bool
    var prewarm: @Sendable () async throws -> Void
    var sendMessage: @Sendable (_ userMessage: String, _ history: [Message]) async throws -> AsyncThrowingStream<String, Error>
    var clearHistory: @Sendable () -> Void
}

extension ChatRepository {
    static let live: ChatRepository = {
        let session = LanguageModelSession()

        return ChatRepository(
            isAvailable: {
                SystemLanguageModel.default.isAvailable
            },
            prewarm: {
                // SystemLanguageModel does not require explicit warmup
            },
            sendMessage: { userMessage, history in
                AsyncThrowingStream { continuation in
                    Task {
                        do {
                            let stream = session.streamResponse(
                                to: userMessage
                            )

                            for try await partialResponse in stream {
                                continuation.yield(partialResponse.content)
                            }
                            continuation.finish()
                        } catch {
                            continuation.finish(throwing: error)
                        }
                    }
                }
            },
            clearHistory: {
                // Session state is managed internally by LanguageModelSession
            }
        )
    }()

    static let mock = ChatRepository(
        isAvailable: { true },
        prewarm: { },
        sendMessage: { userMessage, _ in
            AsyncThrowingStream { continuation in
                Task {
                    let mockResponse = "This is a mock response to: \(userMessage)"
                    for char in mockResponse {
                        try? await Task.sleep(for: .milliseconds(20))
                        continuation.yield(String(char))
                    }
                    continuation.finish()
                }
            }
        },
        clearHistory: { }
    )
}

// MARK: - Environment

private struct ChatRepositoryKey: EnvironmentKey {
    static let defaultValue = ChatRepository.live
}

extension EnvironmentValues {
    var chatRepository: ChatRepository {
        get { self[ChatRepositoryKey.self] }
        set { self[ChatRepositoryKey.self] = newValue }
    }
}
