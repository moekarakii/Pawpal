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
    
    // This starts our default location centered on San Francisco
    // Want to replace it with the user's location data if available
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    // array of lost pets fetched from data base (init)
    @State private var lostPets: [LostPet] = []
    
    // A shared Firestore reference to make it more intuitave for reuse
    private let db = Firestore.firestore()
    
    // LocationManager object manages access to CoreLocation updates
    @StateObject private var locationManager = LocationManager()
    
    // Used to confirm when we’ve successfully centered on the user
    @State private var hasCenteredOnUser = false
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(lostPets) { pet in
                Marker(pet.petName, coordinate: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude))
            }
        }
        .onAppear(perform: fetchLostPets)
        .navigationTitle("Lost Pets Map")
    }
    
    
    
    private func fetchLostPets() {
        db.collection("lost_pets").getDocuments { snapshot, error in
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
                
                return LostPet(id: doc.documentID, petName: name, description: desc, latitude: lat, longitude: lng)
            }
        }
    }
}

#Preview {
    LostPetMapView()
}
