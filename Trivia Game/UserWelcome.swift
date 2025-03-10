//
//  UserWelcome.swift
//  Trivia Game
//
//  Created by Kritika  on 3/3/25.
//

import SwiftUI

struct UserWelcome: View {
    var body: some View {
            NavigationStack{
                ZStack{
                    Color.black
                        .ignoresSafeArea()
                    VStack{
                        Image("brain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding()
                        Text("Welcome to the World of Trivia")
                            .foregroundStyle(.white)
                            .bold()
                        NavigationLink(destination: HomeView()) {
                            Text("Play Now")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
            }
        }
    }

#Preview {
    UserWelcome()
}
