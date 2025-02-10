//
//  BoardCell.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import SwiftUI

struct BoardCell: View {
    
    let type: CellType
    let state: CellState
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    switch type {
                    case .regular:
                        /// ┼
                        path.move(to: CGPoint(x: 0, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width, y: height * 0.5))
                        path.move(to: CGPoint(x: width * 0.5, y: 0))
                        path.addLine(to: CGPoint(x: width * 0.5, y: height))
                        
                    case .topLeft:
                        /// ┌
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width, y: height * 0.5))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width * 0.5, y: height))
                        path.closeSubpath()
                        
                    case .topRight:
                        /// ┐
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: 0, y: height * 0.5))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width * 0.5, y: height))
                        path.closeSubpath()
                        
                    case .bottomLeft:
                        /// └
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width * 0.5, y: 0))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width, y: height * 0.5))
                        path.closeSubpath()
                        
                    case .bottomRight:
                        /// ┘
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width * 0.5, y: 0))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: 0, y: height * 0.5))
                        path.closeSubpath()
                        
                    case .top:
                        /// ┬
                        path.move(to: CGPoint(x: 0, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width, y: height * 0.5))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width * 0.5, y: height))
                        path.closeSubpath()
                        
                    case .left:
                        /// ├
                        path.move(to: CGPoint(x: width * 0.5, y: 0))
                        path.addLine(to: CGPoint(x: width * 0.5, y: height))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width, y: height * 0.5))
                        path.closeSubpath()
                        
                    case .right:
                        /// ┤
                        path.move(to: CGPoint(x: width * 0.5, y: 0))
                        path.addLine(to: CGPoint(x: width * 0.5, y: height))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: 0, y: height * 0.5))
                        path.closeSubpath()
                        
                    case .bottom:
                        /// ┴
                        path.move(to: CGPoint(x: 0, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width, y: height * 0.5))
                        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
                        path.addLine(to: CGPoint(x: width * 0.5, y: 0))
                        path.closeSubpath()
                    }
                }
                .stroke(Color(ColorResource.line), lineWidth: 1)
            }
            
            GeometryReader { geometry in
                switch state {
                case .empty:
                    EmptyView()
                case .white:
                    Piece(isBlack: false)
                        .frame(
                            width: geometry.size.width * 0.7,
                            height: geometry.size.height * 0.7
                        )
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                case .black:
                    Piece(isBlack: true)
                        .foregroundStyle(Color.black)
                        .frame(
                            width: geometry.size.width * 0.7,
                            height: geometry.size.height * 0.7
                        )
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            
            GeometryReader { geometry in
                switch state {
                case .empty:
                    EmptyView()
                case .white(let selected):
                    if selected {
                        PieceSelection()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                case .black(let selected):
                    if selected {
                        PieceSelection()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
    }
}
