//
//  EnterProfileViewController.swift
//  PawPal
//
//  Created by Hieu Hoang on 12/15/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class EnterProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton! // Upload button
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var petTypeTextField: UITextField!
    @IBOutlet weak var petAgeTextField: UITextField!
    @IBOutlet weak var petCharacteristicsTextField: UITextField!
    @IBOutlet weak var petDescriptionTextView: UITextView!

    // MARK: - Properties
    private let storageRef = Storage.storage().reference() // Reference to Firebase Storage

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Set delegates for the text fields
        petNameTextField.delegate = self
        petTypeTextField.delegate = self
        petAgeTextField.delegate = self
        petCharacteristicsTextField.delegate = self
    }

    // MARK: - Setup
    func setupUI() {
        // Style the image view
        petImageView.layer.cornerRadius = petImageView.frame.size.width / 2
        petImageView.clipsToBounds = true
        petImageView.layer.borderWidth = 1
        petImageView.layer.borderColor = UIColor.gray.cgColor
    }

    // MARK: - Actions
    @IBAction func uploadImageTapped(_ sender: UIButton) {
        // Present the image picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            petImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        // Validate input
        guard let name = petNameTextField.text, !name.isEmpty,
              let type = petTypeTextField.text, !type.isEmpty,
              let age = petAgeTextField.text, !age.isEmpty,
              let characteristics = petCharacteristicsTextField.text, !characteristics.isEmpty,
              let description = petDescriptionTextView.text, !description.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        // Upload image and save profile
        if let image = petImageView.image {
            uploadImageToFirebase(image: image) { [weak self] imageURL in
                self?.saveProfileToFirestore(name: name, type: type, age: age, characteristics: characteristics, description: description, imageURL: imageURL)
            }
        } else {
            // Save profile without image
            saveProfileToFirestore(name: name, type: type, age: age, characteristics: characteristics, description: description, imageURL: nil)
        }
    }

    private func uploadImageToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not authenticated.")
            completion(nil)
            return
        }

        let imageRef = storageRef.child("user_profiles/\(userId)/pet_image.jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            showAlert(message: "Failed to compress image.")
            completion(nil)
            return
        }

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.showAlert(message: "Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    self.showAlert(message: "Failed to retrieve image URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                completion(url?.absoluteString)
            }
        }
    }


    private func saveProfileToFirestore(name: String, type: String, age: String, characteristics: String, description: String, imageURL: String?) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not authenticated.")
            return
        }

        let db = Firestore.firestore()
        var profileData: [String: Any] = [
            "name": name,
            "type": type,
            "age": age,
            "characteristics": characteristics.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "description": description
        ]

        if let imageURL = imageURL {
            print("Image URL successfully retrieved: \(imageURL)")
            profileData["imageURL"] = imageURL
        } else {
            print("No image URL retrieved. Saving profile without image.")
        }


        db.collection("user9-s").document(userId).setData(profileData) { error in
            if let error = error {
                self.showAlert(message: "Failed to save profile: \(error.localizedDescription)")
                return
            }

            print("Profile saved successfully.")
            self.performSegue(withIdentifier: "EnterProfileToTabBar", sender: self)
        }
    }

    // MARK: - TextField Placeholder Handling
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            switch textField {
            case petNameTextField:
                textField.placeholder = "Enter Pet's Name"
            case petTypeTextField:
                textField.placeholder = "Enter Pet's Type"
            case petAgeTextField:
                textField.placeholder = "Enter Pet's Age"
            case petCharacteristicsTextField:
                textField.placeholder = "Enter Pet's Characteristics"
            default:
                break
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
