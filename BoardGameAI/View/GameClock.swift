//
//  Clock.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import SwiftUI

struct GameClock: View {
    @State private var currentClock: String = "🕐"
    private let clocks: [String] = ["🕐", "🕑", "🕒", "🕓", "🕔", "🕕", "🕖", "🕗", "🕘", "🕙", "🕚", "🕛"]
    
    var body: some View {
        Text(currentClock)
            .font(.system(size: 30))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    if let currentIndex = clocks.firstIndex(of: currentClock),
                       currentIndex < clocks.count - 1 {
                        currentClock = clocks[currentIndex + 1]
                    } else {
                        currentClock = clocks[0]
                    }
                }
            }
    }
}
