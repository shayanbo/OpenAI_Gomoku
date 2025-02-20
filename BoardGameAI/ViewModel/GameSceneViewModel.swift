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

    /// Dependencies
    private let player1Service: OpenAIService
    private let player2Service: OpenAIService
    private let checkService: CheckService
    
    /// Constructor
    init(
        player1Service: OpenAIService = DefaultOpenAIService(),
        player2Service: OpenAIService = DefaultOpenAIService(),
        checkService: CheckService = DefaultCheckService()
    ) {
        self.player1Service = player1Service
        self.player2Service = player2Service
        self.checkService = checkService
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
        state = .finished
    }
    
    private func start() async {
        do {
            while !state.isFinished {
                
                /// player1 start thinking
                player1.thinking = state.player1Turn
                player2.thinking = state.player2Turn
                
                /// try to get next step from ai
                var battle = if state.player1Turn {
                    try await player1Service.nextStep(player1OrNot: true, instruction: .nextStep, board: pieces)
                } else {
                    try await player2Service.nextStep(player1OrNot: false, instruction: .nextStep, board: pieces)
                }
                
                /// get correct step if wrong
                while pieces[battle.move] != nil {
                    if state.player1Turn {
                        battle = try await player1Service.nextStep(player1OrNot: true, instruction: .wrongStep, board: pieces)
                    } else {
                        battle = try await player2Service.nextStep(player1OrNot: false, instruction: .wrongStep, board: pieces)
                    }
                }

                /// update player card info
                player1.rate = state.player1Turn ? battle.aiWinRate : battle.userWinRate
                player2.rate = state.player2Turn ? battle.aiWinRate : battle.userWinRate
                if state.player1Turn {
                    player1.steps += 1
                    player1.thinkingTime = battle.time
                } else {
                    player2.steps += 1
                    player2.thinkingTime = battle.time
                }
                
                player1.thinking = !state.player1Turn
                player2.thinking = !state.player2Turn
                
                /// update board
                if state.player1Turn {
                    pieces[battle.move] = .black(selected: false)
                } else {
                    pieces[battle.move] = .white(selected: false)
                }
                
                /// check win
                let result = checkService.checkBoard(for: battle.move, in: pieces, by: state.player1Turn)
                switch result {
                case .draw:
                    state = .finished
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
                case .none: /// update game state
                    if state.player1Turn {
                        state = .player2Turn
                    } else {
                        state = .player1Turn
                    }
                case let .win(player1Or2, cells):
                    
                    /// finish the game
                    state = .finished
                    
                    /// update highlighted pieces
                    cells.forEach { location in
                        pieces[location] = player1Or2 ? .black(selected: true) : .white(selected: true)
                    }
                    
                    /// alert result
                    alert = AlertState(
                        title: "\(player1Or2 ? "OpenAI No.1" : "OpenAI No.2") Win!!!",
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
            state = .finished
            
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
