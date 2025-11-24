//
//  WelcomeView.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modified by Moe Karaki on 7/18/25.
//
import SwiftUI

struct WelcomeView: View {
    @State private var logoScale = 0.8
    @State private var textOpacity = 0.0
    @State private var buttonScale = 0.9
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.02),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Spacer(minLength: 80)
                
                // Animated logo
                PawPalLogo(size: 140, showText: true)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                            logoScale = 1.0
                        }
                    }
                
                // Mission statement
                VStack(spacing: 16) {
                    Text("Helping reunite lost pets with their families.")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(textOpacity)
                    
                    Text("Join our community of pet lovers working together to bring every furry friend home safely.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(textOpacity)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                        textOpacity = 1.0
                    }
                }
                
                Spacer(minLength: 40)
                
                // Get Started button
                NavigationLink(destination: LoginView()) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                        
                        Text("Get Started")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .scaleEffect(buttonScale)
                .padding(.horizontal, 40)
                .onAppear {
                    withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.6)) {
                        buttonScale = 1.0
                    }
                }
                
                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
