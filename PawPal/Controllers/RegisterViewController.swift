//
//  RegisterViewController.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//

import UIKit
import FirebaseAuth


class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func registerPressed(_ sender: UIButton) {
        // Validate email and password inputs
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Email or password field is empty.")
            return
        }
        
        // Firebase registration
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                return
            }
            
            print("Registration successful for user: \(authResult?.user.email ?? "No email")")
            // Navigate to the home screen
            self.performSegue(withIdentifier: "RegisterToHome", sender: self)
        }
    }

    // Helper function to show alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
