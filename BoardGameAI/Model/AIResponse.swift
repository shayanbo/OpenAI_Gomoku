//
//  AIResponse.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

enum AIResponse {
    case battle(Battle)
    case gameOver(GameOver)
    
    struct Battle {
        let moveCount: Int
        let time: Int
        let aiWinRate: Double
        let userWinRate: Double
        let move: CellLocation
    }
    
    enum Player: String, Codable {
        case ai
        case user
    }
    
    struct Win: Codable {
        let winner: Player
        let highlight: [CellLocation]
    }
    
    enum GameOver {
        case win(Win)
        case draw
    }
}

extension AIResponse.Battle: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case moveCount = "move_count"
        case time
        case aiWinRate = "ai_win_rate"
        case userWinRate = "user_win_rate"
        case move = "ai_move"
    }
}

extension AIResponse: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case battle
        case gameOver
    }
    
    // Custom encoding for AIResponse
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .battle(let battle):
            try container.encode("battle", forKey: .type)
            try container.encode(battle, forKey: .battle)
        case .gameOver(let gameOver):
            try container.encode("gameOver", forKey: .type)
            try container.encode(gameOver, forKey: .gameOver)
        }
    }
    
    // Custom decoding for AIResponse
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "battle":
            let battle = try container.decode(Battle.self, forKey: .battle)
            self = .battle(battle)
        case "gameOver":
            let gameOver = try container.decode(GameOver.self, forKey: .gameOver)
            self = .gameOver(gameOver)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
}

extension AIResponse.GameOver: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case win
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .win(let result):
            try container.encode("win", forKey: .type)
            try container.encode(result, forKey: .win)
        case .draw:
            try container.encode("draw", forKey: .type)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "win":
            let result = try container.decode(AIResponse.Win.self, forKey: .win)
            self = .win(result)
        case "draw":
            self = .draw
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
}
