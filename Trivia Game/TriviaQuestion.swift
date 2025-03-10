//
//  TriviaQuestion.swift
//  Trivia Game
//
//  Created by Kritika  on 3/9/25.
//

import Foundation
struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaCategory: Codable, Identifiable {
    let id: Int
    let name: String
}
