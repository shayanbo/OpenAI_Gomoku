//
//  AIResponse.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

struct AIResponse {
    let time: Int
    let aiWinRate: Double
    let userWinRate: Double
    let move: CellLocation
}

extension AIResponse: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case time
        case aiWinRate = "ai_win_rate"
        case userWinRate = "user_win_rate"
        case move
    }
}
