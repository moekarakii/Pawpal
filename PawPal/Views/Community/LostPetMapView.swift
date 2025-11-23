//
//  LostPetMapView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

// LostPetMapView.swift
import SwiftUI
import MapKit
import Firebase

struct LostPetMapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    @State private var lostPets: [LostPet] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(lostPets) { pet in
                    Marker(
                        pet.petName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: pet.latitude,
                            longitude: pet.longitude
                        )
                    )
                }
            }

            if isLoading {
                ProgressView("Loading nearby reports...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            if !isLoading && lostPets.isEmpty {
                VStack(spacing: 8) {
                    Text("No reports on the map yet")
                        .font(.headline)
                    Text("When lost pets are reported, they will show up here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .onAppear(perform: fetchLostPets)
        .navigationTitle("Lost Pets Map")
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func fetchLostPets() {
        isLoading = true

        Firestore.firestore().collection(FS.LostPets.collection).getDocuments { snapshot, error in
            isLoading = false

            if let error = error {
                alertMessage = "Failed to load lost pets: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let documents = snapshot?.documents else {
                self.lostPets = []
                return
            }

            self.lostPets = documents.compactMap { doc in
                let data = doc.data()

                guard
                    let name = data[FS.LostPets.petName] as? String,
                    let desc = data[FS.LostPets.description] as? String,
                    let lat = data[FS.LostPets.lat] as? Double,
                    let lng = data[FS.LostPets.lng] as? Double
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

#Preview {
    LostPetMapView()
}
