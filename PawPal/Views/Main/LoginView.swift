//
//  LoginViewController.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modfied by Moe Karaki on 7/15/25
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var navigateToProfileSetup = false
    @State private var navigateToMainApp = false
    @State private var navigateToRegister = false 
    @State private var logoScale = 0.8

    var body: some View {
        NavigationStack {
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

                        // Welcome back text
                        VStack(spacing: 8) {
                            Text("Welcome Back!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Sign in to continue helping pets find their way home")
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

                        // Login buttons
                        VStack(spacing: 16) {
                            Button("Sign In") {
                                loginWithEmail()
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

                            GoogleSignInButton {
                                googleLogin()
                            }
                            .frame(height: 50)
                            .cornerRadius(25)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.horizontal, 20)

                        // Register link
                        Button("Don't have an account? Create one") {
                            navigateToRegister = true
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
            .navigationDestination(isPresented: $navigateToMainApp) {
                MainTabView()
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView()
            }
        }
    }

    private func loginWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email or password field is empty."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            checkUserProfileExists()
        }
    }

    private func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase clientID is missing."
            return
        }

        //This line ensures Google Sign-In uses the correct iOS client ID
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let idToken = result?.user.idToken?.tokenString,
                  let accessToken = result?.user.accessToken.tokenString else {
                errorMessage = "Missing Google ID tokens."
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                checkUserProfileExists()
            }
        }
    }

    private func checkUserProfileExists() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                navigateToMainApp = true
            } else {
                navigateToProfileSetup = true
            }
        }
    }
}

#Preview {
    LoginView()
}
