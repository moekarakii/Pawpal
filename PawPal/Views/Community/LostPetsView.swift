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
import FirebaseFirestore

struct LostPetsView: View {
    @State private var lostPets: [LostPet] = []
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""

    private var filteredPets: [LostPet] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return lostPets
        }
        return lostPets.filter { pet in
            pet.petName.localizedCaseInsensitiveContains(query) ||
            pet.description.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {

        // Removed NavigationStack wrapper earlier to fix toolbar duplication
        Group {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView("Loading reports…")
                    Text("Fetching recent lost pet reports")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if lostPets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 42))
                        .foregroundStyle(.secondary)
                    Text("No reports yet")
                        .font(.headline)
                    Text("Be the first to submit a report from the Report tab.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredPets) { pet in
                            NavigationLink(destination: LostPetDetailView(pet: pet)) {
                                LostPetRow(pet: pet)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .refreshable {
                    fetchLostPets()
                }
            }
        }
        .toolbar {
            // Keeping the title here since you had it before (it would probably better to move this to MainTabView. Will come back to this)
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Lost Pets")
                    .font(.headline)
            }

            // Removed duplicate logout since we are having the MainTabView Handle this now. 
        }
        .onAppear(perform: fetchLostPets)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search by name or description"
        )
        .alert("Oops", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func fetchLostPets() {
        isLoading = true
        Firestore.firestore()
            .collection(FS.LostPets.collection)
            .order(by: FS.LostPets.timestamp, descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error {
                        alertMessage = error.localizedDescription
                        showAlert = true
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        lostPets = []
                        return
                    }

                    self.lostPets = documents.compactMap { doc in
                        let data = doc.data()
                        guard
                            let name = data[FS.LostPets.petName] as? String,
                            let desc = data[FS.LostPets.description] as? String,
                            let lat  = data[FS.LostPets.lat] as? Double,
                            let lng  = data[FS.LostPets.lng] as? Double
                        else {
                            return nil
                        }

                        let timestamp = (data[FS.LostPets.timestamp] as? Timestamp)?.dateValue()

                        return LostPet(
                            id: doc.documentID,
                            petName: name,
                            description: desc,
                            latitude: lat,
                            longitude: lng,
                            timestamp: timestamp
                        )
                    }
                }
            }
    }
}

#Preview {
    LostPetsView()
}
