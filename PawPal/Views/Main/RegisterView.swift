//
//  RegisterView.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modifed by Moe Karaki on 7/18/25.
//
import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var navigateToProfileSetup = false
    @State private var logoScale = 0.8

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
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 60)
                    
                    // PawPal Logo
                    PawPalLogo(size: 100, showText: true)
                        .scaleEffect(logoScale)
                        .onAppear {
                            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                                logoScale = 1.0
                            }
                        }

                    // Welcome text
                    VStack(spacing: 8) {
                        Text("Join PawPal")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Create your account and start helping pets in your community")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Form fields
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Register button
                    Button("Create Account") {
                        register()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    .padding(.horizontal, 20)

                    // Login link
                    Button("Already have an account? Sign in") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.medium)

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToProfileSetup) {
            EnterProfileView()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }

    private func register() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email or password field is empty."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            print("Registration successful for user: \(result?.user.email ?? "No email")")
            navigateToProfileSetup = true
        }
    }
}

#Preview {
    RegisterView()
}
