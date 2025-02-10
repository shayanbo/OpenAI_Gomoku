//
//  Player.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import DeveloperToolsSupport
import SwiftUI

struct GamePlayer {
    let avatar: Color
    let name: String
    var rate: Double
    var steps: Int
    var thinkingTime = 0
    var thinking: Bool = false
}

extension GamePlayer {
    static var player1 = GamePlayer(avatar: .black, name: "OpenAI No.1", rate: 0, steps: 0)
    static var player2 = GamePlayer(avatar: .white, name: "OpenAI No.2", rate: 0, steps: 0)
}
