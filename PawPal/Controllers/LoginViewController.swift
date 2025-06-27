//
//  LoginViewController.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Email/Password Login
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Email or password field is empty.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            print("Email login successful for user: \(authResult?.user.email ?? "No email")")
            self.checkUserProfileExists()
        }
    }

    // Google Login
    @IBAction func googleLoginPressed(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert(title: "Error", message: "Firebase clientID is missing.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                return
            }

            guard let idToken = result?.user.idToken?.tokenString,
                  let accessToken = result?.user.accessToken.tokenString else {
                self.showAlert(title: "Google Sign-In Failed", message: "Missing tokens.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Firebase Sign-In Failed", message: error.localizedDescription)
                    return
                }

                print("Google login successful for user: \(authResult?.user.email ?? "No email")")
                self.checkUserProfileExists()
            }
        }
    }

    // Check Firestore for Existing Profile
    private func checkUserProfileExists() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                print("User profile exists, navigating to TabBarViewController.")
                self.performSegue(withIdentifier: "LoginToTabBar", sender: self)
            } else {
                print("No user profile found, navigating to EnterProfileViewController.")
                self.performSegue(withIdentifier: "LoginToEnterProfile", sender: self)
            }
        }
    }



    // Helper Method for Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
