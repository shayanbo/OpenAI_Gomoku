//
//  Defines.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

#error("replace it with the real stuff")
let OPENAI_API_KEY = "<OPENAI_API_KEY>"

var boardSize = 10

enum CellType {
    case regular
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case top
    case left
    case right
    case bottom
}

enum CellState: Equatable {
    case empty 
    case white(selected: Bool)
    case black(selected: Bool)
}

struct CellLocation: Hashable, Codable {
    let row: Int
    let column: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(column)
    }
}

struct BoardSize {
    let rows: Int
    let columns: Int
}

enum GameState {
    case ready
    case player1Turn
    case player2Turn
    case finished
}

extension GameState {
    
    var isFinished: Bool {
        if case .finished = self {
            return true
        }
        return false
    }
    
    var player1Turn: Bool {
        if case .player1Turn = self {
            return true
        } else if case .ready = self {
            return true
        }
        return false
    }
    
    var player2Turn: Bool {
        if case .player2Turn = self {
            return true
        }
        return false
    }
}

extension CellType {
    
    init(size: BoardSize, row: Int, column: Int) {
        if row == 0 && column == 0 {
            self = .topLeft
        } else if row == 0 && column == size.columns - 1 {
            self = .topRight
        } else if row == 0 && column > 0 && column < size.columns - 1 {
            self = .top
        } else if row == size.rows - 1 && column == 0 {
            self = .bottomLeft
        } else if row == size.rows - 1 && column == size.columns - 1 {
            self = .bottomRight
        } else if row == size.rows - 1 && column > 0 && column < size.columns - 1 {
            self = .bottom
        } else if column == 0 {
            self = .left
        } else if column == size.columns - 1 {
            self = .right
        } else {
            self = .regular
        }
    }
}
