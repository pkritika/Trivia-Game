
//  HomeView.swift
//  Trivia Game
//
//  Created by Kritika  on 2/27/25.


import SwiftUI

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
}

struct CategoryResponse: Codable {
    let trivia_categories: [Category]
}

struct HomeView: View {
    @State private var categories: [Category] = []
    @State private var selectedCategory = 0
    @State private var selectedType = 0
    @State private var selectedAmount = 5
    @State private var timerDuration = 0
    @State private var isLoading = true
    @State private var navigateToGame = false
    
    
    
    let types = ["Any Type", "True or False", "Multiple Choice"]
    let times = ["30", "60", "120"]
    let amounts = [5, 10, 15, 20]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    List {
                        categoryPicker
                        amountPicker
                        typePicker
                        timerPicker
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    
                    Image("3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding()
                    
//                    playNowButton
                    Button("Start Trivia Game") {
                        navigateToGame = true}
                                            .padding()
                                            .background(Color.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                }
            }
            .navigationTitle("Trivia Settings")
            .navigationDestination(isPresented: $navigateToGame) {
                            ContentView(category: selectedCategory, amount: selectedAmount, type: selectedType)
                        }
                    }
                    .onAppear { fetchCategories() }
                }
    
    // MARK: - Computed Properties for Pickers
    
    
    
    private var categoryPicker: some View {
        Picker("Select Category", selection: $selectedCategory) {
            ForEach(0..<categories.count, id: \.self) { index in
                Text(categories[index].name)
                    .foregroundStyle(.white)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .tint(.white)
        .foregroundStyle(.white)
        .listRowBackground(Color.gray.opacity(0.2))
    }
    
    private var amountPicker: some View {
        Picker("Select Number of Questions", selection: $selectedAmount) {
            ForEach(amounts, id: \.self) { amount in
                Text("\(amount)")
                    .foregroundStyle(.white)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .tint(.white)
        .foregroundStyle(.white)
        .listRowBackground(Color.gray.opacity(0.2))
    }
    
    private var typePicker: some View {
        Picker("Select Type", selection: $selectedType) {
            ForEach(0..<types.count, id: \.self) { index in
                Text(types[index])
                    .foregroundStyle(.white)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .tint(.white)
        .foregroundStyle(.white)
        .listRowBackground(Color.gray.opacity(0.2))
    }
    
    private var timerPicker: some View {
        Picker("Timer Duration", selection: $timerDuration) {
            ForEach(0..<times.count, id: \.self) { index in
                Text(times[index])
                    .foregroundStyle(.white)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .tint(.white)
        .foregroundStyle(.white)
        .listRowBackground(Color.gray.opacity(0.2))
    }
    
//    private var playNowButton: some View {
//        navigateToGame = true
//        NavigationLink(
//            destination: ContentView(category: selectedCategory, amount: questionCount, type: selectedType)){
//        }
//    }
    func fetchCategories() {
        let urlString = "https://opentdb.com/api_category.php"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(CategoryResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.categories = decodedResponse.trivia_categories
                    }
                } catch {
                    print("Failed to decode categories: \(error)")
                }
            }
        }.resume()
    }
}

#Preview {
    HomeView()
}
