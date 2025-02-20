//
//  OpenAIService.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

/**
 we don't need to send the whole conversation for each request unless you want, though `chat/completions` is stateless
 */

import Foundation

enum AIError: Error {
    case serverError
    case invalidSession
    case requestError
    case responseFormat
    case apiError(String)
    case userStopped
}

enum Instruction: String {
    case wrongStep = "wrong_step"
    case nextStep = "next_step"
}

protocol OpenAIService {
    func resetSession()
    func nextStep(player1OrNot: Bool, instruction: Instruction, board: [CellLocation: CellState]) async throws(AIError) -> AIResponse
}

class DefaultOpenAIService: OpenAIService {
    
    private var systemPrompt: String {
        guard let path = Bundle.main.path(forResource: "system_prompt", ofType: "txt") else {
            fatalError()
        }
        do {
            var prompt = try String(contentsOfFile: path, encoding: .utf8)
            prompt += "it consists of \(boardSize) x \(boardSize) grid"
            return prompt
        } catch {
            fatalError()
        }
    }
    
    private var session = UUID()
    
    func resetSession() {
        session = UUID()
    }
    
    func nextStep(player1OrNot: Bool, instruction: Instruction, board: [CellLocation: CellState]) async throws(AIError) -> AIResponse {
        /// request
        let currentSession = session
        /// describe current board state with format [column,row,state]
        /// state [0,1,2], 0 means `empty`, 1 means `your piece`, 2 means `opponent's piece`
        var body = instruction == .nextStep ? "instruction:next_step, board state:" : "instruction:wrong_step, board state:"
        (0..<boardSize).forEach { row in
            (0..<boardSize).forEach { column in
                let cellState = board[CellLocation(row: row, column: column)] ?? .empty
                let state = switch cellState {
                case .empty: 0
                case .black: player1OrNot ? 1: 2
                case .white: player1OrNot ? 2: 1
                }
                body += "[\(column),\(row),\(state)],"
            }
        }
        
        let response = try await request(body)
        
        guard currentSession == session else {
            throw AIError.invalidSession
        }
        return response
    }
    
    func request(_ body: String) async throws(AIError) -> AIResponse {
        do {
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")
            
            /// compress whole conversation history to one message to reduce token comsuption
            let data = try JSONEncoder().encode([
                AIMessage(role: "system", content: systemPrompt),
                AIMessage(role: "user", content: body)
            ])
            let messages = try JSONSerialization.jsonObject(with: data)
            
            guard let responseFormatURL = Bundle.main.url(forResource: "response_format", withExtension: "json"),
                  let responseFormatData = try? Data(contentsOf: responseFormatURL),
                  let responseFormat = try? JSONSerialization.jsonObject(with: responseFormatData) else {
                throw AIError.responseFormat
            }
            
            let params = [
                "model": "gpt-4o-mini",
                "messages": messages,
                "response_format": [
                    "type": "json_schema",
                    "json_schema": [
                        "name": "ai_response",
                        "strict": true,
                        "schema": responseFormat
                    ]
                ]
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            let (responseData, response) = try await URLSession.shared.data(for: request as URLRequest)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let response = try JSONDecoder().decode(ChatGPTResponse.self, from: responseData)
                if let content = response.choices.first?.message.content, let data = content.data(using: .utf8) {
                    let response = try JSONDecoder().decode(AIResponse.self, from: data)
                    return response
                }
            } else {
                let json = try JSONSerialization.jsonObject(with: responseData) as? Dictionary<String, Any>
                if let dict = json?["error"] as? Dictionary<String, Any>, let message = dict["message"] as? String {
                    throw AIError.apiError(message)
                }
            }
            throw AIError.serverError
        } catch {
            if let err = error as? AIError {
                throw err
            }
            throw AIError.serverError
        }
    }
}

