//
//  HomeView.swift
//  Trivia Game
//
//  Created by Kritika  on 2/27/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCategory = 0
    @State private var selectedType = 0
    @State private var TimerDuration = 0
    var body: some View {
        let category = ["History", "Animal","Maths"]
        let type = ["Any Type", "True or False","Multiple choice"]
        let time = ["30","60","120"]
        NavigationStack{
            List{
                Picker(selection: $selectedCategory, label: Text("Select Category")) {
                    ForEach(0..<category.count, id: \.self) {
                        Text(category[$0])
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Picker(selection: $selectedType, label: Text("Select Type")) {
                                    ForEach(0..<type.count, id: \.self) {
                                        Text(type[$0])
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                
            }
            NavigationLink("ok"){ContentView()}
        }
    }
}

#Preview {
    HomeView()
}
