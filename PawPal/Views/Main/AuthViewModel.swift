//
//  AuthViewModel.swift
//  PawPal
//
//  Created by Kevin Crapo on 11/26/25.
//


//
//  AuthViewModel.swift
//  PawPal
//
//
//

import FirebaseAuth
import SwiftUI

//Manages the user's authentication state for the entire app.
// This ViewModel ensures SwiftUI reacts to login/logout events
// and restores the Firebase session on app launch.
class AuthViewModel: ObservableObject {
    
    //The currently logged-in Firebase user. `nil` when logged out.
    @Published var user: User?
    
    // Whether the app is still checking Firebase for an existing session.
    @Published var isLoading = true
    
    //Firebase listener handle (kept so we can detach if needed).
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        observeAuthChanges()
    }
    
    // Subscribes to Firebase authentication updates.
    // Called on:
    /// - login
    /// - logout
    /// - app launch (restoring existing session)
    /// - token refresh
    private func observeAuthChanges() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isLoading = false
            }
        }
    }
    
    //Signs out the user safely.
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print("Sign-out failed:", error.localizedDescription)
        }
    }
    
    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
