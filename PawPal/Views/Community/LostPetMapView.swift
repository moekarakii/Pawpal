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
        ZStack(alignment: .topTrailing) {
            //Map View
            Map(position: $cameraPosition) {
                //Display one marker per lost pet document in Firestore
                ForEach(lostPets) { pet in
                    Marker(
                        pet.petName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: pet.latitude,
                            longitude: pet.longitude
                        )
                    )
                }
                
                // Optional marker showing user’s own location if available
                // not sure if i need the annotations but will help with debugging
                if let userLocation = locationManager.location {
                    Annotation("You are here", coordinate: userLocation.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.25))
                                .frame(width: 80, height: 80)
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            // might remove this but testing what happens when we allow the view out of safe bounds
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Lost Pets Map")
            
            
            .onAppear {
                // Begin location tracking (this function has not yet been implemented)
                //                setupUserLocation()
                // Start Firestore real-time listener
                // get rid of perform so that we can run multiple functions
                startListeningForLostPets()
            }
        }
    }
    
    
    
    // original implementation for getting lost pets
    //    private func fetchLostPets() {
    //        db.collection("lost_pets").getDocuments { snapshot, error in
    //            guard let documents = snapshot?.documents else { return }
    //
    //            self.lostPets = documents.compactMap { doc in
    //                let data = doc.data()
    //                guard
    //                    let name = data["petName"] as? String,
    //                    let desc = data["description"] as? String,
    //                    let lat = data["lat"] as? Double,
    //                    let lng = data["lng"] as? Double
    //                else {
    //                    return nil
    //                }
    //
    //                return LostPet(id: doc.documentID, petName: name, description: desc, latitude: lat, longitude: lng)
    //            }
    //        }
    //    }
    
    // fetches lost pets dynamically. The idea is that it will update immediately when another user adds a pet
    private func startListeningForLostPets() {
        db.collection("lost_pets").addSnapshotListener { snapshot, error in
            if let error = error {
                // checking for problems with my snapshotlistener
                print("Firestore listener error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No lost pet documents found.")
                return
            }
            
            // Convert Firestore data into LostPet structs (reused from prior function)
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
                
                // added timestamp to show when the new pet was added (should be useful for urgency)
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                
                return LostPet(
                    id: doc.documentID,
                    petName: name,
                    description: desc,
                    latitude: lat,
                    longitude: lng,
                    timestamp: timestamp
                )
            }
            
            // logging pets added for testing
            print("Firestore updated — \(self.lostPets.count) pets loaded.")
        }
    }
    
    //
    private func setupUserLocation() {
        // Case 1: If we already have a location from the LocationManager
        if let userLocation = locationManager.location {
            moveCameraToUserLocation(userLocation)
        } else {
            // Case 2: If we don’t yet have a location, wait briefly then check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let userLocation = locationManager.location {
                    moveCameraToUserLocation(userLocation)
                } else {
                    // Case 3: Fallback if location is still unavailable (keep the San Fran origin)
                    print(" User location unavailable, using default map center.")
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        )
                    )
                }
            }
        }
    }
    
    // updates camera to center on user location
    // ONLY ONCE (if you let it keep updating the map will keep updating the pin as location manager updates)
    private func moveCameraToUserLocation(_ location: CLLocation) {
        // Prevent recentering repeatedly (only do this the first time)
        guard !hasCenteredOnUser else { return }
        hasCenteredOnUser = true
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )
        
        // logging successful coordinate change
        print("Map centered on user at \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    
}

#Preview {
    LostPetMapView()
}
