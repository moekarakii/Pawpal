//
//  UserProfileView.swift
//  PawPal
//
//  Created by Kevin Crapo on 11/28/25.
//


//
//  UserProfileView.swift
//  PawPal
//
// 
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct UserProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var pets: [LostPet] = []
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                // User Info
                if let user = authVM.user {
                    Text("Logged in as:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(user.email ?? "Unknown email")
                        .font(.headline)
                }

                Divider().padding(.vertical, 4)

                // User’s Pets
                if isLoading {
                    ProgressView("Loading your pets...")
                } else if pets.isEmpty {
                    Text("You haven't reported any pets yet.")
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                } else {
                    List {
                        ForEach(pets) { pet in
                            NavigationLink(destination: LostPetDetailView(pet: pet)) {
                                VStack(alignment: .leading) {
                                    Text(pet.petName)
                                        .font(.headline)
                                    Text(pet.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    deletePet(pet)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Logout Button
                Button(role: .destructive) {
                    authVM.signOut()
                } label: {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

            }
            .padding()
            .navigationTitle("My Profile")
            .onAppear(perform: loadPets)
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func loadPets() {
        guard let uid = authVM.user?.uid else { return }

        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .whereField("userId", isEqualTo: uid)
            .order(by: FS.LostPets.timestamp, descending: true)
            .getDocuments { snapshot, error in

                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    isLoading = false
                    return
                }

                self.pets = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    return LostPet(
                        id: doc.documentID,
                        petName: data[FS.LostPets.petName] as? String ?? "",
                        description: data[FS.LostPets.description] as? String ?? "",
                        latitude: data[FS.LostPets.lat] as? Double ?? 0,
                        longitude: data[FS.LostPets.lng] as? Double ?? 0,
                        timestamp: (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue(),
                        userId: data["userId"] as? String
                    )
                } ?? []

                isLoading = false
            }
    }

    private func deletePet(_ pet: LostPet) {
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .document(pet.id)
            .delete { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }

                pets.removeAll { $0.id == pet.id }
            }
    }
}
