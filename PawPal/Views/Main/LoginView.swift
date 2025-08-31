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

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Login with Email") {
                    loginWithEmail()
                }
                .buttonStyle(.borderedProminent)

                GoogleSignInButton {
                    googleLogin()
                }
                .frame(height: 44)
                
                Button("Don't have an account? Register") {
                    navigateToRegister = true
                }
                
                .navigationDestination(isPresented: $navigateToProfileSetup) {
                    EnterProfileView()
                }
                 
                .navigationDestination(isPresented: $navigateToMainApp) {
                    //MainAppView()
                    MainTabView()
                }
                
                .navigationDestination(isPresented: $navigateToRegister) {
                    RegisterView()
                }
            }
            .padding()
            .navigationTitle("Login")
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
            //checkUserProfileExists()
            navigateToMainApp = true
        }
    }

    private func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase clientID is missing."
            return
        }

        //let config = GIDConfiguration(clientID: clientID)
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

                //checkUserProfileExists()
                navigateToMainApp = true 
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
