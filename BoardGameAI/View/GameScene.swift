import SwiftUI

struct GameScene: View {
    
    @StateObject var viewModel = GameSceneViewModel()
    
    let cellSize: CGFloat = 30
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    
                    Spacer().frame(maxHeight: .infinity)
                    PlayerInfoCard(player: viewModel.player1, alignment: .leading, color: .blue)
                        .padding(.horizontal, 6)
                    
                    Board(
                        size: BoardSize(
                            rows: UInt(geometry.size.width / cellSize),
                            columns: UInt(geometry.size.width / cellSize)
                        ),
                        cell: cellSize,
                        pieces: viewModel.pieces
                    )
                    .background(Color(ColorResource.board))
                    .cornerRadius(4)
                    .padding(.vertical, 10)
                    
                    PlayerInfoCard(player: viewModel.player2, alignment: .trailing, color: .red)
                        .padding(.horizontal, 6)
                    Spacer().frame(maxHeight: .infinity)
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("OpenAI vs OpenAI")
                            .fontWeight(.heavy)
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            Task { await viewModel.handleAction(.tapStartButton) }
                        }) {
                            Group {
                                switch viewModel.state {
                                case .ready:
                                    Image(systemName: "play.circle")
                                case .player1Turn, .player2Turn:
                                    Image(systemName: "pause.circle")
                                case .finished:
                                    Image(systemName: "forward.end.circle")
                                }
                            }
                            .foregroundStyle(Color.white.opacity(0.9))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .background(Color(ColorResource.background))
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertState: $viewModel.alert) { action in
                await viewModel.handleAction(action)
            }
        }
    }
}
