//
//  AIResponseTest.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/9.
//

import Testing
import Foundation
@testable import BoardGameAI

class AIResponseTest {

    @Test func battle() async throws {
        let content = try contentOfFile("battle")
        let response = try JSONDecoder().decode(AIResponse.self, from: content)
        switch response {
        case let .battle(battle):
            #expect(battle.steps == 15)
            #expect(battle.time == 120)
            #expect(battle.aiWinRate == 0.65)
            #expect(battle.userWinRate == 0.35)
            #expect(battle.step.row == 4)
            #expect(battle.step.column == 6)
        case .gameOver:
            Issue.record("should be battle")
        }
    }
    
    @Test func gameOverDraw() async throws {
        let content = try contentOfFile("gameOver_draw")
        let response = try JSONDecoder().decode(AIResponse.self, from: content)
        switch response {
        case .battle:
            Issue.record("should be gameOver")
        case let .gameOver(gameOver):
            switch gameOver {
            case .draw:
                #expect(true)
            case .win:
                Issue.record("should be draw")
            }
        }
    }
    
    @Test func gameOverWin() async throws {
        let content = try contentOfFile("gameOver_win")
        let response = try JSONDecoder().decode(AIResponse.self, from: content)
        switch response {
        case .battle:
            Issue.record("should be gameOver")
        case let .gameOver(gameOver):
            switch gameOver {
            case .draw:
                Issue.record("should be win")
            case let .win(result):
                #expect(result.winner == .user)
                #expect(result.highlight.count == 5)
                #expect(result.highlight[0].row == 1)
                #expect(result.highlight[0].column == 1)
                #expect(result.highlight[1].row == 2)
                #expect(result.highlight[1].column == 2)
                #expect(result.highlight[2].row == 3)
                #expect(result.highlight[2].column == 3)
                #expect(result.highlight[3].row == 4)
                #expect(result.highlight[3].column == 4)
                #expect(result.highlight[4].row == 5)
                #expect(result.highlight[4].column == 5)
            }
        }
    }
    
    private func contentOfFile(_ fileName: String) throws -> Data {
        let testBundle = Bundle(for: AIResponseTest.self)
        let url = try #require(testBundle.url(forResource: fileName, withExtension: "json"))
        return try Data(contentsOf: url)
    }
}
