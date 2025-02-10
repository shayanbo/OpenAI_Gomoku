//
//  AlertState.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/9.
//

import SwiftUI

struct AlertState<Action> {
    
    enum ActionStyle {
        case `default`
        case cancel
        case destructive
    }
    
    struct ActionState {
        let title: String
        let action: Action?
        let style: ActionStyle
    }
    
    enum ButtonLayout {
        case dismiss(ActionState)
        case primaryAndSecondary(primary: ActionState, secondary: ActionState)
    }
    
    let title: String?
    let message: String?
    let buttonLayout: ButtonLayout
}

extension View {
    
    func alert<Action>(alertState: Binding<AlertState<Action>?>, actionHandler: @escaping (Action) async -> Void) -> some View {
        
        let boolBinding = Binding<Bool> {
            alertState.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                alertState.wrappedValue = nil
            }
        }

        return alert(isPresented: boolBinding) {
            
            if let alertState = alertState.wrappedValue {
                switch alertState.buttonLayout {
                case let .primaryAndSecondary(primary: primaryAction, secondary: secondaryAction):
                    Alert(
                        title: Text(alertState.title ?? ""),
                        message: Text(alertState.message ?? ""),
                        primaryButton: button(primaryAction, actionHandler),
                        secondaryButton: button(secondaryAction, actionHandler)
                    )
                case let .dismiss(dismissAction):
                    Alert(
                        title: Text(alertState.title ?? ""),
                        message: Text(alertState.message ?? ""),
                        dismissButton: button(dismissAction, actionHandler)
                    )
                }
            } else {
                fatalError()
            }
        }
    }
    
    private func button<Action>(_ actionState: AlertState<Action>.ActionState, _ actionHandler: @escaping (Action) async -> Void) -> Alert.Button {
        switch actionState.style {
        case .cancel:
            .cancel(Text(actionState.title)) {
                Task {
                    if let action = actionState.action {
                        await actionHandler(action)
                    }
                }
            }
        case .default:
            .default(Text(actionState.title)) {
                Task {
                    if let action = actionState.action {
                        await actionHandler(action)
                    }
                }
            }
        case .destructive:
            .destructive(Text(actionState.title)) {
                Task {
                    if let action = actionState.action {
                        await actionHandler(action)
                    }
                }
            }
        }
    }
}
