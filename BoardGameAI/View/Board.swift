//
//  Board.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import SwiftUI

struct Board: View {

    let size: BoardSize
    var cell: CGFloat = 30.0
    
    let pieces: [CellLocation: CellState]
    
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<size.rows, id: \.self) { row in
                GridRow {
                    ForEach(0..<size.columns, id: \.self) { column in
                        BoardCell(
                            type: CellType(size: size, row: row, column: column),
                            state: pieces[CellLocation(row: row, column: column)] ?? .empty
                        )
                        .frame(width: cell, height: cell)
                    }
                }
            }
        }
        .background(Color.brown)
    }
}
