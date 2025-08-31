//
//  LostPetsView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

// LostPetsView.swift
import SwiftUI
import Firebase
import FirebaseAuth
import MapKit

struct LostPetsView: View {
    @State private var lostPets: [LostPet] = []
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(lostPets) { pet in
                        NavigationLink(destination: LostPetDetailView(pet: pet)) {
                            LostPetRow(pet: pet)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Lost Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear(perform: fetchLostPets)
        }
    }

    private func fetchLostPets() {
        Firestore.firestore().collection("lost_pets").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            self.lostPets = documents.compactMap { doc in
                let data = doc.data()
                guard
                    let name = data["petName"] as? String,
                    let desc = data["description"] as? String,
                    let lat = data["lat"] as? Double,
                    let lng = data["lng"] as? Double
                else {
                    return nil
                }

                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()

                return LostPet(id: doc.documentID, petName: name, description: desc, latitude: lat, longitude: lng, timestamp: timestamp)
            }
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            dismiss()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LostPetsView()
}
