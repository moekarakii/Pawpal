//
//  WelcomeView.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modified by Moe Karaki on 7/18/25.
//
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("🐾 Welcome to PawPal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Helping reunite lost pets with their families.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                NavigationLink(destination: LoginView()) {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
