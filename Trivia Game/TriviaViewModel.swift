//
//  TriviaViewModel.swift
//  Trivia Game
//
//  Created by Kritika  on 3/9/25.
//

import Foundation

class TriviaViewModel: ObservableObject {
    @Published var question: TriviaQuestion?
    @Published var choices: [String] = []
    
    // Add parameters to be used in the API request
    var category: Int
    var amount: Int
    var type: Int
    
    // Initializer to accept category, amount, and type
    init(category: Int, amount: Int, type: Int) {
        self.category = category
        self.amount = amount
        self.type = type
    }

    func fetchQuestion() {
        let urlString = "https://opentdb.com/api.php?amount=\(amount)&category=\(category)&type=\(type)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let fetchedQuestion = decodedResponse.results.first {
                            self.question = fetchedQuestion
                            self.choices = (fetchedQuestion.incorrect_answers + [fetchedQuestion.correct_answer]).shuffled()
                        }
                    }
                } catch {
                    print("Error decoding: \(error)")
                }
            }
        }.resume()
    }
}
