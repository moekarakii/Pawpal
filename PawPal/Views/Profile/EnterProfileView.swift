//
//  EnterProfileView.swift
//  PawPal
//
//  Created by Hieu Hoang on 12/15/24.
//  Modified by Moe Karaki on 7/15/25.
//
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct EnterProfileView: View {
    @State private var petImage: UIImage?
    @State private var showImagePicker = false

    @State private var petName = ""
    @State private var petType = ""
    @State private var petAge = ""
    @State private var petCharacteristics = ""
    @State private var petDescription = ""

    @State private var errorMessage: String?
    @State private var navigateToMainApp = false

    var body: some View {
        VStack(spacing: 16) {
            if let image = petImage {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            } else {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2))
                    .frame(width: 150, height: 150)
                    .overlay(Text("Upload Pet Photo"))
            }

            Button("Upload Image") {
                showImagePicker = true
            }

            Group {
                TextField("Pet Name", text: $petName)
                TextField("Pet Type", text: $petType)
                TextField("Pet Age", text: $petAge)
                TextField("Characteristics (comma-separated)", text: $petCharacteristics)
                TextEditor(text: $petDescription)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button("Submit") {
                validateAndUpload()
            }
            .buttonStyle(.borderedProminent)

            NavigationStack {
                NavigationLink(value: "mainApp") {
                    EmptyView()
                }
                .navigationDestination(for: String.self) { value in
                    if value == "mainApp" {
                        MainAppView()
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $petImage)
        }
        .navigationTitle("Set Up Pet Profile")
    }

    private func validateAndUpload() {
        guard !petName.isEmpty, !petType.isEmpty, !petAge.isEmpty,
              !petCharacteristics.isEmpty, !petDescription.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        if let image = petImage {
            uploadImage(image) { imageURL in
                saveProfile(imageURL: imageURL)
            }
        } else {
            saveProfile(imageURL: nil)
        }
    }

    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            completion(nil)
            return
        }

        let imageRef = Storage.storage().reference().child("users/\(uid)/pet_image.jpg")
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Could not compress image"
            completion(nil)
            return
        }

        imageRef.putData(data, metadata: nil) { _, error in
            if let error = error {
                errorMessage = "Image upload failed: \(error.localizedDescription)"
                completion(nil)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    errorMessage = "Failed to get image URL: \(error.localizedDescription)"
                    completion(nil)
                    return
                }

                completion(url?.absoluteString)
            }
        }
    }

    private func saveProfile(imageURL: String?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }

        var profile: [String: Any] = [
            "name": petName,
            "type": petType,
            "age": petAge,
            "characteristics": petCharacteristics.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            "description": petDescription
        ]

        if let imageURL = imageURL {
            profile["imageURL"] = imageURL
        }

        Firestore.firestore().collection("users").document(uid).setData(profile) { error in
            if let error = error {
                errorMessage = "Failed to save profile: \(error.localizedDescription)"
                return
            }

            navigateToMainApp = true
        }
    }
}
