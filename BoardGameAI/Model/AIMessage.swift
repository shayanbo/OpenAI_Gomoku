//
//  History.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import Foundation

struct AIMessage: Codable {
    let role: String
    let content: String
}

extension AIResponse {
    var message: AIMessage? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        guard let content = String(data: data, encoding: .utf8) else {
            return nil
        }
        return AIMessage(role: "assistant", content: content)
    }
}
