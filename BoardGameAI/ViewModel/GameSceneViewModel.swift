//
//  GameSceneViewModel.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

import Combine

/**
 Player1 -> OpenAI No.1 (Black Piece) [First Step]
 Player2 -> OpenAI No.2 (White Piece)
 */

@MainActor class GameSceneViewModel: ObservableObject {
    
    /// State
    @Published private(set) var pieces = [CellLocation: CellState]()
    @Published private(set) var player1 = GamePlayer.player1
    @Published private(set) var player2 = GamePlayer.player2
    @Published private(set) var state: GameState = .ready
    @Published var alert: AlertState<Action>?
    
    /// Misc
    private var lastStep: CellLocation?
    
    /// Dependencies
    private let player1Service: OpenAIService
    private let player2Service: OpenAIService
    
    /// Constructor
    init(player1Service: OpenAIService = DefaultOpenAIService(), player2Service: OpenAIService = DefaultOpenAIService()) {
        self.player1Service = player1Service
        self.player2Service = player2Service
    }
    
    /// Action
    enum Action: Equatable {
        case tapRestartButton
        case tapStartButton
        case tapStopButton
    }
    
    /// Reduce
    func handleAction(_ action: Action) async {
        switch action {
        case .tapStartButton:
            await tapStartButton()
        case .tapRestartButton:
            await tapRestartButton()
        case .tapStopButton:
            await tapStopButton()
        }
    }
    
    private func tapRestartButton() async {
        
        pieces = [CellLocation: CellState]()
        player1 = GamePlayer.player1
        player2 = GamePlayer.player2
        state = .ready
        alert = nil
        player1Service.resetSession()
        player2Service.resetSession()
        
        await start()
    }
    
    private func tapStartButton() async {
        switch state {
        case .ready:
            state = .player1Turn
            await start()
        case .player1Turn, .player2Turn:
            alert = AlertState(
                title: "Would you want to stop?",
                message: nil,
                buttonLayout: .primaryAndSecondary(
                    primary: .init(
                        title: "Confirm",
                        action: .tapStopButton,
                        style: .default
                    ),
                    secondary: .init(
                        title: "Cancel",
                        action: nil,
                        style: .destructive
                    )
                )
            )
        case .finished:
            alert = AlertState(
                title: "Would you want one more round?",
                message: nil,
                buttonLayout: .primaryAndSecondary(
                    primary: .init(
                        title: "Confirm",
                        action: .tapRestartButton,
                        style: .default
                    ),
                    secondary: .init(
                        title: "Cancel",
                        action: nil,
                        style: .destructive
                    )
                )
            )
        }
    }
    
    private func tapStopButton() async {
        state = .finished(.failure(AIError.userStopped))
    }
    
    private func start() async {
        do {
            while !state.isFinished {
                
                /// player1's turn
                if state.player1Turn {
                    
                    /// player1 start thinking
                    player1.thinking = true
                    
                    /// try to get next step from ai
                    let response = try await player1Service.resolve(userStep: lastStep)
                    
                    /// handle response
                    switch response {
                    case let .battle(battle):
                        
                        /// update player card info
                        player1.rate = battle.aiWinRate
                        player2.rate = battle.userWinRate
                        player1.steps = battle.moveCount
                        player1.thinkingTime = battle.time
                        player1.thinking = false
                        
                        /// update board
                        pieces[battle.move] = .black(selected: false)
                        
                        /// misc for player2
                        lastStep = battle.move
                        
                        /// update game state
                        state = .player2Turn
                        
                    case let .gameOver(gameOver):
                        state = .finished(.success(gameOver))
                        
                        switch gameOver {
                        case .win(let result):
                            
                            /// update highlighted pieces
                            result.highlight.forEach { location in
                                pieces[location] = result.winner == .ai ? .black(selected: true) : .white(selected: true)
                            }
                            
                            /// alert result
                            alert = AlertState(
                                title: "\(result.winner == .ai ? "OpenAI No.1" : "OpenAI No.2") Win!!!",
                                message: "Would you want one more round?",
                                buttonLayout: .primaryAndSecondary(
                                    primary: .init(
                                        title: "Confirm",
                                        action: .tapRestartButton,
                                        style: .default
                                    ),
                                    secondary: .init(
                                        title: "Cancel",
                                        action: nil,
                                        style: .destructive
                                    )
                                )
                            )
                        case .draw:
                            alert = AlertState(
                                title: "Draw",
                                message: "Would you want one more round",
                                buttonLayout: .primaryAndSecondary(
                                    primary: .init(
                                        title: "Confirm",
                                        action: .tapRestartButton,
                                        style: .default
                                    ),
                                    secondary: .init(
                                        title: "Cancel",
                                        action: nil,
                                        style: .destructive
                                    )
                                )
                            )
                        }
                    }
                } else {
                    
                    /// player2 start thinking
                    player2.thinking = true
                    
                    /// try to get next step from ai
                    let response = try await player2Service.resolve(userStep: lastStep)
                    
                    /// handle response
                    switch response {
                    case let .battle(battle):
                        
                        /// update player card info
                        player2.rate = battle.aiWinRate
                        player1.rate = battle.userWinRate
                        player2.steps = battle.moveCount
                        player2.thinkingTime = battle.time
                        player2.thinking = false
                        
                        /// update board
                        pieces[battle.move] = .white(selected: false)
                        
                        /// misc for player1
                        lastStep = battle.move
                        
                        /// update game state
                        state = .player1Turn
                        
                    case let .gameOver(gameOver):
                        state = .finished(.success(gameOver))
                        
                        switch gameOver {
                        case .win(let result):
                            
                            /// update highlighted pieces
                            result.highlight.forEach { location in
                                pieces[location] = result.winner == .ai ? .white(selected: true) : .black(selected: true)
                            }
                            
                            /// alert result
                            alert = AlertState(
                                title: "\(result.winner == .ai ? "OpenAI No.2" : "OpenAI No.1") Win!!!",
                                message: "Would you want one more round?",
                                buttonLayout: .primaryAndSecondary(
                                    primary: .init(
                                        title: "Confirm",
                                        action: .tapRestartButton,
                                        style: .default
                                    ),
                                    secondary: .init(
                                        title: "Cancel",
                                        action: nil,
                                        style: .destructive
                                    )
                                )
                            )
                        case .draw:
                            alert = AlertState(
                                title: "Draw",
                                message: "Would you want one more round",
                                buttonLayout: .primaryAndSecondary(
                                    primary: .init(
                                        title: "Confirm",
                                        action: .tapRestartButton,
                                        style: .default
                                    ),
                                    secondary: .init(
                                        title: "Cancel",
                                        action: nil,
                                        style: .destructive
                                    )
                                )
                            )
                        }
                    }
                }
            }
        } catch {
            /// user shouldn't be displayed with invalid session error since it's triggered by user
            if case .invalidSession = error {
                return
            }
            
            var alertTitle = "Something unexpected occured"
            if case let .apiError(message) = error {
                alertTitle = message
            }
            
            /// game is interrupted by an error
            state = .finished(.failure(error))
            /// pop up an alert
            alert = AlertState(
                title: alertTitle,
                message: "Would you like to restart?",
                buttonLayout: .primaryAndSecondary(
                    primary: .init(
                        title: "Confirm",
                        action: .tapRestartButton,
                        style: .default
                    ),
                    secondary: .init(
                        title: "Cancel",
                        action: nil,
                        style: .destructive
                    )
                )
            )
        }
    }
}
