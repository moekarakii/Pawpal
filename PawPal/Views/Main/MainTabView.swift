//
//  MainTabView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

// MainTabView.swift

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {
            LostPetsView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Logout") {
                            logout()
                        }
                        .foregroundColor(.red)
                    }
                }
                .tabItem {
                    Label("Browse", systemImage: "list.bullet")
                }

            LostPetMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            LostPetReportView()
                .tabItem {
                    Label("Report", systemImage: "plus.circle")
                }
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            dismiss() // This pops MainTabView off the stack
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainTabView()
}

