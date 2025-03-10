//
//  ContentView.swift
//  Trivia Game
//
//  Created by Kritika  on 2/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: TriviaViewModel
    @State private var selectedAnswer: String?
    @State private var showAlert = false
    @State private var isCorrect = false
    @State private var score = 0
    let category: Int
    let amount: Int
    let type: Int
    
    init(category: Int, amount: Int, type: Int) {
        _viewModel = StateObject(wrappedValue: TriviaViewModel(category: category, amount: amount, type: type))
        self.category = category
        self.amount = amount
        self.type = type
    }
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack {
                if let question = viewModel.question {
                    Spacer()
                    Text("Category: \(question.category)")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                    
                    Text(question.question)
                        .font(.title2)
                        .padding()
                        .foregroundStyle(.white)
                    
                    ForEach(viewModel.choices, id: \.self) { answer in
                        Button(action: {
                            withAnimation {
                                selectedAnswer = answer
                                isCorrect = (answer == question.correct_answer)
                                showAlert = true
                                
                                if isCorrect{
                                    score += 5
                                }
                            }
                        }) {
                            Text(answer)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedAnswer == answer
                                            ? (isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                            : Color.gray.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                    Text("Score: \(score)")
                        .fontWeight(.bold)
                        .font(.system(size: 30))
                                        .foregroundStyle(.white)
                                        .padding()
                Spacer()
                    Button("Next Question") {
                        viewModel.fetchQuestion()
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel.fetchQuestion()
                        }
                }
            }
            
        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text(isCorrect ? "Correct!" : "Wrong!"),
//                  message: Text(isCorrect ? "Great job!" : "The correct answer was \(viewModel.question?.correct_answer ?? "")"),
//                  dismissButton: .default(Text("OK")))
        }
}

#Preview {
    ContentView(category: 0, amount: 5, type: 0)
}
