import SwiftUI

struct ContentView: View {
    @State private var numberOfQuestions = 10
    @State private var selectedCategory: Int?
    @State private var selectedDifficulty: String?
    @State private var selectedType: String?
    @State private var isGameActive = false
    @State private var selectedTime = 60
    
    @State private var categories: [TriviaCategory] = []
    @State private var isLoadingCategories = true
    @State private var categoryError: String? = nil
    
    let triviaService = TriviaService()
    let difficulties = ["easy", "medium", "hard"]
    let types = [("multiple", "Multiple Choice"), ("boolean", "True / False")]
    
    private var isFormValid: Bool {
        return selectedCategory != nil && selectedDifficulty != nil && selectedType != nil
    }
    
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "FFB6C1"), Color(hex: "E6E6FA"), Color(hex: "98FB98")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                    .opacity(0.3)
                
                VStack(spacing: 0) {
                    headerView
                    
                    scrollContent
                }
            }
            .navigationTitle("Sparkle Trivia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sparkle Trivia")
                        .font(.title3.bold())
                        .foregroundColor(Color(hex: "B76E79"))
                }
            }
            .onAppear {
                loadCategories()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 5) {
            Image(systemName: "star.sparkle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "B76E79"))
                .padding(.top, 20)
            
            Text("Design Your Trivia")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "B76E79"))
            
            Text("Create your fabulous quiz challenge")
                .font(.subheadline)
                .foregroundColor(Color(hex: "B76E79").opacity(0.7))
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.5))
    }
    
    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Questions Counter
                configCard(title: "Number of Questions", systemImage: "heart.circle.fill") {
                    VStack(spacing: 10) {
                        Text("\(numberOfQuestions)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "B76E79"))
                            .frame(maxWidth: .infinity)
                        
                        Slider(value: Binding(
                            get: { Double(numberOfQuestions) },
                            set: { numberOfQuestions = Int($0) }
                        ), in: 1...50, step: 1)
                        .accentColor(Color(hex: "B76E79"))
                        
                        Text("1 question minimum, 50 maximum")
                            .font(.caption)
                            .foregroundColor(Color(hex: "B76E79").opacity(0.7))
                    }
                    .padding(.horizontal, 5)
                }
                
                // Category Selection
                configCard(title: "Category", systemImage: "sparkles") {
                    if isLoadingCategories {
                        HStack {
                            Spacer()
                            ProgressView("Loading categories...")
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "B76E79")))
                            Spacer()
                        }
                    } else if let error = categoryError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    } else {
                        categoryPicker
                    }
                }
                
                configCard(title: "Difficulty", systemImage: "heart.fill") {
                    difficultyPicker
                }
                
                configCard(title: "Question Type", systemImage: "star.circle.fill") {
                    typePicker
                }
                
                configCard(title: "Time Limit", systemImage: "clock.fill") {
                    VStack(spacing: 10) {
                        Text("\(selectedTime) seconds")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "B76E79"))
                            .frame(maxWidth: .infinity)
                        
                        Slider(value: Binding(
                            get: { Double(selectedTime) },
                            set: { selectedTime = Int($0) }
                        ), in: 10...120, step: 5)
                        .accentColor(Color(hex: "B76E79"))
                        
                        Text("10 seconds minimum, 120 seconds maximum")
                            .font(.caption)
                            .foregroundColor(Color(hex: "B76E79").opacity(0.7))
                    }
                    .padding(.horizontal, 5)
                }
                
                startGameButton
                    .padding(.vertical, 20)
            }
            .padding()
        }
    }
    
    private var categoryPicker: some View {
        Menu {
            ForEach(categories) { category in
                Button(action: {
                    selectedCategory = category.id
                }) {
                    HStack {
                        Text(category.name)
                        if selectedCategory == category.id {
                            Image(systemName: "heart.fill")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(categories.first(where: { $0.id == selectedCategory })?.name ?? "Select a category")
                    .foregroundColor(selectedCategory == nil ? .secondary : Color(hex: "B76E79"))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: "B76E79"))
            }
            .padding()
            .background(Color.white.opacity(0.7))
            .cornerRadius(15)
        }
        .foregroundColor(.primary)
    }
    
    private var difficultyPicker: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(difficulties, id: \.self) { difficulty in
                    difficultyButton(difficulty)
                }
            }
            
            Text(selectedDifficulty == nil ? "Select a difficulty level" : "Selected: \(selectedDifficulty?.capitalized ?? "")")
                .font(.caption)
                .foregroundColor(Color(hex: "B76E79").opacity(0.7))
        }
    }
    
    private func difficultyButton(_ difficulty: String) -> some View {
        let isSelected = selectedDifficulty == difficulty
        
        let difficultyColor: Color = {
            switch difficulty {
            case "easy": return Color(hex: "98FB98")  // Soft Mint
            case "medium": return Color(hex: "FFB6C1")  // Blush Pink
            case "hard": return Color(hex: "C8A2C8")  // Soft Lilac
            default: return .gray
            }
        }()
        
        return Button(action: {
            selectedDifficulty = difficulty
        }) {
            VStack {
                Image(systemName: {
                    switch difficulty {
                    case "easy": return "heart.fill"
                    case "medium": return "star.fill"
                    case "hard": return "sparkles"
                    default: return "questionmark"
                    }
                }())
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : difficultyColor)
                
                Text(difficulty.capitalized)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : difficultyColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? difficultyColor : Color.white.opacity(0.5))
            .cornerRadius(20)
        }
    }
    
    private var typePicker: some View {
        VStack(spacing: 10) {
            HStack {
                ForEach(types, id: \.0) { type in
                    typeButton(type)
                }
            }
            
            Text(selectedType == nil ? "Select a question type" : "Selected: \(types.first(where: { $0.0 == selectedType })?.1 ?? "")")
                .font(.caption)
                .foregroundColor(Color(hex: "B76E79").opacity(0.7))
        }
    }
    
    private func typeButton(_ type: (String, String)) -> some View {
        let isSelected = selectedType == type.0
        
        return Button(action: {
            selectedType = type.0
        }) {
            VStack {
                Image(systemName: type.0 == "multiple" ? "list.bullet.heart.fill" : "arrow.left.and.right.heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: "B76E79"))
                
                Text(type.1)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : Color(hex: "B76E79"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "B76E79") : Color.white.opacity(0.5))
            .cornerRadius(20)
        }
    }
    
    private var startGameButton: some View {
        NavigationLink(
            destination: TriviaGameView(
                viewModel: {
                    let vm = TriviaGameViewModel()
                    if let category = selectedCategory,
                       let difficulty = selectedDifficulty,
                       let type = selectedType {
                        vm.loadQuestions(
                            amount: numberOfQuestions,
                            category: category,
                            difficulty: difficulty,
                            type: type
                        )
                    }
                    return vm
                }(),
                timeLimit: selectedTime
            ),
            isActive: $isGameActive
        ) {
            HStack {
                Image(systemName: "sparkles")
                Text("Start Sparkle Challenge")
                    .fontWeight(.bold)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 40)
            .background(
                isFormValid ?
                LinearGradient(gradient: Gradient(colors: [Color(hex: "B76E79"), Color(hex: "FFB6C1")]), startPoint: .leading, endPoint: .trailing) :
                LinearGradient(gradient: Gradient(colors: [Color.gray]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(25)
            .shadow(color: isFormValid ? Color(hex: "B76E79").opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .disabled(!isFormValid)
        .onTapGesture {
            if isFormValid {
                isGameActive = true
            }
        }
    }
    
    private func configCard<Content: View>(title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "B76E79"))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "B76E79"))
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color(hex: "B76E79").opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func loadCategories() {
        isLoadingCategories = true
        categoryError = nil
        
        triviaService.fetchCategories { result in
            DispatchQueue.main.async {
                isLoadingCategories = false
                
                switch result {
                case .success(let fetchedCategories):
                    self.categories = fetchedCategories
                case .failure(let error):
                    print("Error fetching categories: \(error.localizedDescription). Using fallback categories.")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
