//
//  MainAppView.swift
//  PawPal
//
//  Created by Moe Karaki on 7/15/25.
//
import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to PawPal!")
                    .font(.title)

                Button("Logout") {
                    logout()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            .navigationTitle("PawPal")
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            dismiss() // This pops the current view off the navigation stack
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainAppView()
}
