

import SwiftUI

class TriviaGameViewModel: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var userAnswers: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var score = 0
    @Published var answersSubmitted = false
    
    private let triviaService = TriviaService()
    
    func loadQuestions(amount: Int, category: Int, difficulty: String, type: String) {
        isLoading = true
        errorMessage = nil
        
        triviaService.fetchTrivia(amount: amount, category: category, difficulty: difficulty, type: type) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let questions):
                    self?.questions = questions
                    self?.userAnswers = Array(repeating: "", count: questions.count)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func selectAnswer(questionIndex: Int, answer: String) -> Bool {
        if questionIndex < userAnswers.count {
            userAnswers[questionIndex] = answer
            return questions[questionIndex].correctAnswer == answer
        }
        return false
    }
    
    func submitAnswers() -> Int {
        score = 0
        
        for (index, question) in questions.enumerated() {
            if index < userAnswers.count && userAnswers[index] == question.correctAnswer {
                score += 1
            }
        }
        
        answersSubmitted = true
        return score
    }
}



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
