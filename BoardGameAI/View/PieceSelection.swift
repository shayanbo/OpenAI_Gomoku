//
//  PieceSelection.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/9.
//

import SwiftUI

struct PieceSelection : View {
    
    var body: some View {
        
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let offset: CGFloat = 2
                let length: CGFloat = 10
                
                /// ┌
                path.move(to: CGPoint(x: offset, y: offset))
                path.addLine(to: CGPoint(x: offset, y: offset + length))
                path.move(to: CGPoint(x: offset, y: offset))
                path.addLine(to: CGPoint(x: offset + length, y: offset))
                
                /// ┐
                path.move(to: CGPoint(x: width - offset, y: offset))
                path.addLine(to: CGPoint(x: width - offset - length, y: offset))
                path.move(to: CGPoint(x: width - offset, y: offset))
                path.addLine(to: CGPoint(x: width - offset, y: offset + length))
                
                /// └
                path.move(to: CGPoint(x: offset, y: height - offset))
                path.addLine(to: CGPoint(x: offset, y: height - offset - length))
                path.move(to: CGPoint(x: offset, y: height - offset))
                path.addLine(to: CGPoint(x: offset + length, y: height - offset))
                
                /// ┘
                path.move(to: CGPoint(x: width - offset, y: height - offset))
                path.addLine(to: CGPoint(x: width - offset - length, y: height - offset))
                path.move(to: CGPoint(x: width - offset, y: height - offset))
                path.addLine(to: CGPoint(x: width - offset, y: height - offset - length))
                
                /// finished
                path.closeSubpath()
            }
            .stroke(Color(ColorResource.selection), lineWidth: 1)
        }
    }
}
