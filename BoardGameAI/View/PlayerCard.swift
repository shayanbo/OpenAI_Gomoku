//
//  PlayerCard.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import SwiftUI

struct PlayerInfoCard: View {
    let player: GamePlayer
    let alignment: HorizontalAlignment
    let color: Color
    
    var body: some View {
        VStack(alignment: alignment, spacing: 10) {
            
            HStack {
                
                if alignment == .trailing {
                    if player.thinking {
                        GameClock()
                    }
                    Spacer()
                }
                
                player.avatar
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                
                Text(player.name)
                    .font(.custom("STKaiti", size: 16))
                    .foregroundColor(.primary)
                    .shadow(color: Color.gray.opacity(0.4), radius: 2)
                
                if alignment == .leading {
                    Spacer()
                    if player.thinking {
                        GameClock()
                    }
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            HStack {
                
                VStack(alignment: alignment) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 16))
                        
                        Text("Win Rate: \(player.rate)")
                            .font(.custom("STKaiti", size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 16))
                        
                        Text("Move Count: \(player.steps)")
                            .font(.custom("STKaiti", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}
