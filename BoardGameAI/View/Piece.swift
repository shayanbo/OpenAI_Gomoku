//
//  Piece.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/9.
//

import SwiftUI

struct Piece: View {
    var isBlack: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width
            ZStack {
                /// piece
                Circle()
                    .fill(isBlack ? Color.black : Color.white)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(isBlack ? Color.black : Color.white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 6, x: 2, y: 2)

                /// spotlight
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: size / 3, height: size / 3)
                    .offset(x: -size / 4, y: -size / 4)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
