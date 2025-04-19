import SwiftUI

struct TriviaGameView: View {
    @ObservedObject var viewModel: TriviaGameViewModel
    @State private var showingResults = false
    @State private var timeRemaining: Int
    @State private var timer: Timer? = nil
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: TriviaGameViewModel, timeLimit: Int = 60) {
        self.viewModel = viewModel
        _timeRemaining = State(initialValue: timeLimit)
    }
    
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "FFB6C1"), Color(hex: "E6E6FA"), Color(hex: "98FB98")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
                .opacity(0.15)
                
            if viewModel.isLoading {
                LoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage, presentationMode: presentationMode)
            } else {
                gameContentView
            }
        }
        .navigationTitle("Sparkle Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Sparkle Challenge")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "B76E79"))
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var gameContentView: some View {
        VStack(spacing: 0) {
            timerView
                .padding(.horizontal)
                
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(viewModel.questions.enumerated()), id: \.element.id) { index, question in
                        QuestionCardView(
                            index: index,
                            question: question,
                            userAnswer: index < viewModel.userAnswers.count ? viewModel.userAnswers[index] : "",
                            showResult: viewModel.answersSubmitted,
                            onAnswerSelected: { answer in
                                let _ = viewModel.selectAnswer(questionIndex: index, answer: answer)
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            submitButton
        }
        .alert(isPresented: $showingResults) {
            Alert(
                title: Text("Sparkle Results"),
                message: Text("Your score: \(viewModel.score) out of \(viewModel.questions.count)"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private var timerView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.pink.opacity(0.2), radius: 5, x: 0, y: 2)
            
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(timeRemaining < 10 ? .red : Color(hex: "B76E79"))
                    .font(.system(size: 18, weight: .bold))
                
                ProgressView(value: Double(timeRemaining), total: 60)
                    .progressViewStyle(LinearProgressViewStyle(tint: timeRemaining < 10 ? .red : Color(hex: "B76E79")))
                    .frame(height: 8)
                
                Text("\(timeRemaining)s")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(timeRemaining < 10 ? .red : Color(hex: "B76E79"))
                    .frame(width: 40)
            }
            .padding()
        }
        .frame(height: 60)
        .padding(.vertical, 10)
    }
    
    private var submitButton: some View {
        Button(action: {
            let _ = viewModel.submitAnswers()
            showingResults = true
            timer?.invalidate()
        }) {
            Text("Submit Sparkle Answers")
                .font(.headline.bold())
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "B76E79"), Color(hex: "FFB6C1")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .padding()
        .disabled(viewModel.userAnswers.contains("") || showingResults || viewModel.answersSubmitted)
        .opacity(viewModel.userAnswers.contains("") || showingResults || viewModel.answersSubmitted ? 0.6 : 1)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                let _ = viewModel.submitAnswers()
                showingResults = true
            }
        }
    }
}

struct QuestionCardView: View {
    let index: Int
    let question: TriviaQuestion
    let userAnswer: String
    let showResult: Bool
    let onAnswerSelected: (String) -> Void
    
    private var difficultyColor: Color {
        switch question.difficulty {
        case "easy":
            return Color(hex: "98FB98")  // Soft Mint
        case "medium":
            return Color(hex: "FFB6C1")  // Blush Pink
        case "hard":
            return Color(hex: "C8A2C8")  // Soft Lilac
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Question \(index + 1)")
                    .font(.headline.bold())
                    .foregroundColor(Color(hex: "B76E79"))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(question.difficulty.capitalized)
                        .font(.footnote.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor)
                        .cornerRadius(12)
                    
                    Text(question.category.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? question.category)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "B76E79"))
                        .lineLimit(1)
                }
            }
            
            Text(question.question.decodedHTML())
                .font(.body)
                .fontWeight(.medium)
                .padding(.vertical, 5)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 8) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    AnswerButton(
                        answer: answer.decodedHTML(),
                        isSelected: userAnswer == answer,
                        isCorrect: answer == question.correctAnswer,
                        isAnswered: !userAnswer.isEmpty,
                        showResult: showResult,
                        action: {
                            onAnswerSelected(answer)
                        }
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color(hex: "B76E79").opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    let showResult: Bool
    let action: () -> Void
    
    private var backgroundColor: Color {
        if showResult && isAnswered {
            if isSelected {
                return isCorrect ? Color(hex: "98FB98").opacity(0.2) : Color(hex: "FFB6C1").opacity(0.2)
            } else if isCorrect {
                return Color(hex: "98FB98").opacity(0.2)
            } else {
                return Color.white.opacity(0.5)
            }
        } else {
            return isSelected ? Color(hex: "B76E79").opacity(0.1) : Color.white.opacity(0.5)
        }
    }
    
    private var borderColor: Color {
        if showResult && isAnswered {
            if isSelected {
                return isCorrect ? Color(hex: "98FB98") : Color(hex: "FFB6C1")
            } else if isCorrect {
                return Color(hex: "98FB98")
            } else {
                return Color.gray.opacity(0.3)
            }
        } else {
            return isSelected ? Color(hex: "B76E79") : Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(answer)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(
                        showResult && isSelected ?
                            (isCorrect ? Color(hex: "98FB98") : Color(hex: "FFB6C1")) :
                            (isSelected ? Color(hex: "B76E79") : .primary)
                    )
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if showResult && isAnswered {
                    if isSelected {
                        Image(systemName: isCorrect ? "heart.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? Color(hex: "98FB98") : Color(hex: "FFB6C1"))
                            .font(.system(size: 18))
                    } else if isCorrect {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(hex: "98FB98"))
                            .font(.system(size: 18))
                    }
                } else if isSelected {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "B76E79"))
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAnswered)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "B76E79")))
            
            Text("Sparkling Questions...")
                .font(.headline)
                .foregroundColor(Color(hex: "B76E79"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.9))
    }
}

struct ErrorView: View {
    let errorMessage: String
    let presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "FFB6C1"))
            
            Text("Oops!")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "B76E79"))
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(Color(hex: "B76E79"))
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Return to Sparkle") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.headline)
            .padding()
            .foregroundColor(.white)
            .background(Color(hex: "B76E79"))
            .cornerRadius(10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color(hex: "B76E79").opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}
