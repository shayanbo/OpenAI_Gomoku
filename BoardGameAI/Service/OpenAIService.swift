//
//  OpenAIService.swift
//  BoardGameAI
//
//  Created by shayanbo on 2025/2/8.
//

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
    func nextStep(userStep: CellLocation?, instruction: Instruction, board: [CellLocation: CellState]) async throws(AIError) -> AIResponse
}

class DefaultOpenAIService: OpenAIService {
    
    private static let systemPrompt = """
        You are the best Gomoku player in the world, and now you are playing it, the board is like Go consisting of \(boardSize) x \(boardSize) grid, pieces can only be placed on the intersections, which will be refered by (row, column), two players take turns placing respective pieces on the available intersection which means the intersection has no piece on. two players keep placing step by step until no more available intersections which means draw, or until either player form 5 consecutive its pieces horizantally, vertically or diagonally, which means win. Two players use different colored pieces: white, black. the player with black pieces go first. it's good to start with the middle. 
    
        Request Content:
        - When receive next_step, it means your opponent give the next step for you
        - When receive wrong_step, it means the intersection of your step has been occupied, please give other available step
    
        Trick:
        - Pieces can only be placed on empty intersection
        - When there is empty intersection between your pieces, fill these gap to form consecutive pieces
        - When you have 4 same consecutive pieces horizantally, vertically or diagonally, place one pieces to form 5 pieces if possible
        - When you have 3 same consecutive pieces horizantally, vertically or diagonally, place one pieces to form 4 pieces if possible
        - When you have 2 same consecutive pieces horizantally, vertically or diagonally, place one pieces to form 3 pieces if possible
        - When you have 1 same consecutive pieces horizantally, vertically or diagonally, place one pieces to form 2 pieces if possible
        - Place piece to prevent opponent from forming consecutive pieces
    """
    
    private var history = [AIMessage(role: "system", content: systemPrompt)]
    private var session = UUID()
    
    func resetSession() {
        session = UUID()
        history = [AIMessage(role: "system", content: DefaultOpenAIService.systemPrompt)]
    }
    
    func nextStep(userStep: CellLocation?, instruction: Instruction, board: [CellLocation: CellState]) async throws(AIError) -> AIResponse {
        /// put user message to history
        if let step = userStep {
            let body = [
                "don't return move showing up in these moves": board.description,
                instruction.rawValue: "row:\(step.row), column:\(step.column)"
            ]
            history.append(AIMessage(role: "user", content: body.description))
        }
        /// request
        let currentSession = session
        let response = try await request()
        guard currentSession == session else {
            throw AIError.invalidSession
        }
        /// put ai response to history
        if let message = response.message {
            history.append(message)
        }
        return response
    }
    
    func request() async throws(AIError) -> AIResponse {
        do {
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")
            
            let data = try JSONEncoder().encode(history)
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

