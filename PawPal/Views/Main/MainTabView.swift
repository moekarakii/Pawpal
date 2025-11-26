//
//  MainTabView.swift
//  PawPal
//
//  Created by Juan Zavala on 8/17/25.
//
//  This view is the main tab bar container shown after the user successfully logs in.
//  It holds the three primary sections of the app: Browse (LostPetsView),
//  Map (LostPetMapView), and Report (LostPetReportView).
//  A logout button is provided in the navigation bar of the Browse tab.
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    
    // Inject global authentication state.
    // This allows this view (and others) to call `authVM.signOut()`
    // which cleanly logs out the user and resets the app's root view.
    @EnvironmentObject var authVM: AuthViewModel

    //Don't think we need this anymore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {

            // Browse Tab (Lost Pets List)
            // Contains a logout button that uses the global
            // AuthViewModel instead of local logout logic.
            // Wrapped in its own NavigationStack to avoid
            // toolbar duplication and disappearance.
            NavigationStack {
                LostPetsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Logout") {
                                authVM.signOut()
                            }
                            .foregroundColor(.red)
                        }
                    }
            }
            .tabItem {
                Label("Browse", systemImage: "list.bullet")
            }

            // Map Tab — wrapped in NavigationStack to ensure
            // consistent navigation behavior across tabs.
          
            NavigationStack {
                LostPetMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            
            NavigationStack {
                LostPetReportView()
            }
            .tabItem {
                Label("Report", systemImage: "plus.circle")
            }
        }
    }
}

#Preview {
    MainTabView()
}
