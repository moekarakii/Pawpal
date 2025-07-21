//
//  AuthService.swift
//  PawPal
//
//  Created by Hieu Hoang on 1/5/25.
//


import FirebaseAuth

class AuthService {
    static let shared = AuthService()

    func registerUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            completion(error)
        }
    }

    func loginUser(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(error)
        }
    }

    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
