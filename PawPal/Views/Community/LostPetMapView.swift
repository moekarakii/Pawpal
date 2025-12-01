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

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(lostPets) { pet in
                Marker(pet.petName, coordinate: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude))
            }
        }
        .onAppear(perform: fetchLostPets)
        .navigationTitle("Lost Pets Map")
    }

    /// Mirrors the list fetch but only keeps what the map needs.
    private func fetchLostPets() {
        Firestore.firestore().collection("lost_pets").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            self.lostPets = documents.compactMap { doc in
                let data = doc.data()
                // Support both `lat/lng` and `latitude/longitude`.
                let lat = data["lat"] as? Double ?? data["latitude"] as? Double
                let lng = data["lng"] as? Double ?? data["longitude"] as? Double

                guard
                    let name = data["petName"] as? String,
                    let desc = data["description"] as? String,
                    let lat,
                    let lng
                else {
                    return nil
                }

                let photoURL = data["photoURL"] as? String // passed along so detail/list can show the image

                return LostPet(id: doc.documentID,
                                petName: name,
                                description: desc,
                                latitude: lat,
                                longitude: lng,
                                photoURL: photoURL)
            }
        }
    }
}

#Preview {
    LostPetMapView()
}
