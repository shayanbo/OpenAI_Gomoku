//
//  CheckService.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/11.
//

enum CheckResult {
    case draw
    case win(player1Or2: Bool, cells: [CellLocation])
    case none
}

protocol CheckService {
    func checkBoard(for position: CellLocation, in board: [CellLocation: CellState], by player1Or2: Bool) -> CheckResult
}

class DefaultCheckService: CheckService {
    
    func checkBoard(for position: CellLocation, in board: [CellLocation: CellState], by player1Or2: Bool) -> CheckResult {
        
        /// horizontal check
        let winHorizontally = ((position.row - 4)...(position.row)).first { row in
            let target: CellState = player1Or2 ? .black(selected: false) : .white(selected: false)
            let failed = (0...4).contains { offset in
                board[CellLocation(row: row + offset, column: position.column)] != target
            }
            return !failed
        }
        if let row = winHorizontally {
            let cells = (0...4).reduce([CellLocation]()) { partialResult, offset in
                partialResult + [CellLocation(row: row + offset, column: position.column)]
            }
            return .win(player1Or2: player1Or2, cells: cells)
        }
        
        /// vertical check
        let winVertically = ((position.column - 4)...(position.column)).first { column in
            let target: CellState = player1Or2 ? .black(selected: false) : .white(selected: false)
            let failed = (0...4).contains { offset in
                board[CellLocation(row: position.row, column: column + offset)] != target
            }
            return !failed
        }
        if let column = winVertically {
            let cells = (0...4).reduce([CellLocation]()) { partialResult, offset in
                partialResult + [CellLocation(row: position.row, column: column + offset)]
            }
            return .win(player1Or2: player1Or2, cells: cells)
        }
        
        /// primary diagnal check
        let rowColumnsPrimarily = (-4...0).map { (Int(position.row) + $0, Int(position.column) + $0) }
        let winPrimaryDiagonally = rowColumnsPrimarily.first { (row, column) in
            let target: CellState = player1Or2 ? .black(selected: false) : .white(selected: false)
            let failed = (0...4).contains { offset in
                board[CellLocation(row: row + offset, column: column + offset)] != target
            }
            return !failed
        }
        if let rowColumn = winPrimaryDiagonally {
            let cells = (0...4).reduce([CellLocation]()) { partialResult, offset in
                partialResult + [CellLocation(row: rowColumn.0 + offset, column: rowColumn.1 + offset)]
            }
            return .win(player1Or2: player1Or2, cells: cells)
        }
                                    
        /// secondary diagnal check
        let rowColumnsSecondarily = (-4...0).map { (Int(position.row) + $0, Int(position.column) - $0) }
        let winSecondaryDiagonally = rowColumnsSecondarily.first { (row, column) in
            let target: CellState = player1Or2 ? .black(selected: false) : .white(selected: false)
            let failed = (0...4).contains { offset in
                board[CellLocation(row: row + offset, column: column - offset)] != target
            }
            return !failed
        }
        if let rowColumn = winSecondaryDiagonally {
            let cells = (0...4).reduce([CellLocation]()) { partialResult, offset in
                partialResult + [CellLocation(row: rowColumn.0 + offset, column: rowColumn.1 - offset)]
            }
            return .win(player1Or2: player1Or2, cells: cells)
        }
        
        return .none
    }
}
