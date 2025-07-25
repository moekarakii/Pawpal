//
//  PawPalApp.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//
import SwiftUI
import Firebase

@main
struct PawPalApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView() // we can change this to LoginView or HomeView if needed
        }
    }
}
