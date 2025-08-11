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

    var body: some View {
        VStack(spacing: 20) {
            Text("Create an Account")
                .font(.title)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Register") {
                register()
            }
            .buttonStyle(.borderedProminent)

            Button("Already have an account? Log in") {
                dismiss()
            }

            .navigationDestination(isPresented: $navigateToProfileSetup) {
                EnterProfileView()
            }
        }
        .padding()
        .navigationTitle("Register")
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
