//
//  CheckServiceTest.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/11.
//

import Testing
import Foundation
@testable import BoardGameAI

class CheckServiceTest {
    
    let service = DefaultCheckService()
    
    @Test func simpleVerticalSuccessfulCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 2, column: 4): .black(selected: false),
            CellLocation(row: 3, column: 4): .black(selected: false),
            CellLocation(row: 4, column: 4): .black(selected: false),
            CellLocation(row: 5, column: 4): .black(selected: false),
            CellLocation(row: 6, column: 4): .black(selected: false),
        ]
        let location = CellLocation(row: 2, column: 4)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        if case let .win(player1Or2, cells) = result {
            #expect(player1Or2 == true)
            #expect(cells.count == 5)
            #expect(cells[0].row == 2 && cells[0].column == 4)
            #expect(cells[1].row == 3 && cells[1].column == 4)
            #expect(cells[2].row == 4 && cells[2].column == 4)
            #expect(cells[3].row == 5 && cells[3].column == 4)
            #expect(cells[4].row == 6 && cells[4].column == 4)
        } else {
            Issue.record("should be win")
        }
    }
    
    @Test func simpleVerticalOtherPlayerCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 2, column: 4): .black(selected: false),
            CellLocation(row: 3, column: 4): .black(selected: false),
            CellLocation(row: 4, column: 4): .white(selected: false),
            CellLocation(row: 5, column: 4): .black(selected: false),
            CellLocation(row: 6, column: 4): .black(selected: false),
        ]
        let location = CellLocation(row: 2, column: 4)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        guard case .none = result else {
            Issue.record("should be none")
            return
        }
    }
    
    @Test func simpleVerticalFailedCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 2, column: 4): .black(selected: false),
            CellLocation(row: 3, column: 4): .black(selected: false),
            CellLocation(row: 4, column: 4): .black(selected: true),
            CellLocation(row: 5, column: 4): .black(selected: false),
            CellLocation(row: 6, column: 4): .black(selected: false),
        ]
        let location = CellLocation(row: 2, column: 4)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        guard case .none = result else {
            Issue.record("should be none")
            return
        }
    }
    
    @Test func simpleVerticalFailedSkipCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 2, column: 4): .black(selected: false),
            CellLocation(row: 3, column: 4): .black(selected: false),
            CellLocation(row: 5, column: 4): .black(selected: false),
            CellLocation(row: 6, column: 4): .black(selected: false),
            CellLocation(row: 7, column: 4): .black(selected: false),
        ]
        let location = CellLocation(row: 2, column: 4)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        guard case .none = result else {
            Issue.record("should be none")
            return
        }
    }
    
    @Test func simpleHorizontalSuccessfulCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 2, column: 1): .black(selected: false),
            CellLocation(row: 2, column: 2): .black(selected: false),
            CellLocation(row: 2, column: 3): .black(selected: false),
            CellLocation(row: 2, column: 4): .black(selected: false),
            CellLocation(row: 2, column: 5): .black(selected: false),
        ]
        let location = CellLocation(row: 2, column: 1)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        if case let .win(player1Or2, cells) = result {
            #expect(player1Or2 == true)
            #expect(cells.count == 5)
            #expect(cells[0].row == 2 && cells[0].column == 1)
            #expect(cells[1].row == 2 && cells[1].column == 2)
            #expect(cells[2].row == 2 && cells[2].column == 3)
            #expect(cells[3].row == 2 && cells[3].column == 4)
            #expect(cells[4].row == 2 && cells[4].column == 5)
        } else {
            Issue.record("should be win")
        }
    }
    
    @Test func simplePrimaryDiagonalSuccessfulCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 1, column: 1): .black(selected: false),
            CellLocation(row: 2, column: 2): .black(selected: false),
            CellLocation(row: 3, column: 3): .black(selected: false),
            CellLocation(row: 4, column: 4): .black(selected: false),
            CellLocation(row: 5, column: 5): .black(selected: false),
        ]
        let location = CellLocation(row: 3, column: 3)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        if case let .win(player1Or2, cells) = result {
            #expect(player1Or2 == true)
            #expect(cells.count == 5)
            #expect(cells[0].row == 1 && cells[0].column == 1)
            #expect(cells[1].row == 2 && cells[1].column == 2)
            #expect(cells[2].row == 3 && cells[2].column == 3)
            #expect(cells[3].row == 4 && cells[3].column == 4)
            #expect(cells[4].row == 5 && cells[4].column == 5)
        } else {
            Issue.record("should be win")
        }
    }
    
    @Test func simpleSecondaryDiagonalSuccessfulCheck() {
        
        let board: [CellLocation: CellState] = [
            CellLocation(row: 5, column: 1): .black(selected: false),
            CellLocation(row: 4, column: 2): .black(selected: false),
            CellLocation(row: 3, column: 3): .black(selected: false),
            CellLocation(row: 2, column: 4): .black(selected: false),
            CellLocation(row: 1, column: 5): .black(selected: false),
        ]
        let location = CellLocation(row: 3, column: 3)
        
        let result = service.checkBoard(for: location, in: board, by: true)
        if case let .win(player1Or2, cells) = result {
            #expect(player1Or2 == true)
            #expect(cells.count == 5)
            #expect(cells[4].row == 5 && cells[4].column == 1)
            #expect(cells[3].row == 4 && cells[3].column == 2)
            #expect(cells[2].row == 3 && cells[2].column == 3)
            #expect(cells[1].row == 2 && cells[1].column == 4)
            #expect(cells[0].row == 1 && cells[0].column == 5)
        } else {
            Issue.record("should be win")
        }
    }
}
