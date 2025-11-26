//
//  LostPetMapView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

import SwiftUI
import MapKit
import Firebase

struct LostPetMapView: View {
    @EnvironmentObject var locationManager: LocationManager
    
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
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // A shared Firestore reference to make it more intuitive for reuse
    private let db = Firestore.firestore()
    
    // LocationManager object manages access to CoreLocation updates
    
    
    // Used to confirm when we've successfully centered on the user
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map View
            Map(position: $cameraPosition) {
                // Display one marker per lost pet document in Firestore
                ForEach(lostPets) { pet in
                    Marker(
                        pet.petName,
                        coordinate: CLLocationCoordinate2D(
                            latitude: pet.latitude,
                            longitude: pet.longitude
                        )
                    )
                }
                
                // Optional marker showing user's own location if available
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
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Lost Pets Map")

            // Loading indicator
            if isLoading {
                ProgressView("Loading nearby reports...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            }

            // Empty state message
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
        .onAppear {
            setupUserLocation()
            startListeningForLostPets()
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // Fetches lost pets dynamically with real-time updates
    private func startListeningForLostPets() {
        isLoading = true
        
        db.collection(FS.LostPets.collection).addSnapshotListener { snapshot, error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Failed to load lost pets: \(error.localizedDescription)"
                showAlert = true
                print("Firestore listener error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No lost pet documents found.")
                self.lostPets = []
                return
            }
            
            // Convert Firestore data into LostPet structs
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
            
            print("Firestore updated — \(self.lostPets.count) pets loaded.")
        }
    }
    
    private func setupUserLocation() {
        // Case 1: If we already have a location from the LocationManager
        if let userLocation = locationManager.location {
            moveCameraToUserLocation(userLocation)
        } else {
            // Case 2: If we don't yet have a location, wait briefly then check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let userLocation = locationManager.location {
                    moveCameraToUserLocation(userLocation)
                } else {
                    // Case 3: Fallback if location is still unavailable (keep the San Fran origin)
                    print("User location unavailable, using default map center.")
                }
            }
        }
    }
    
    // Updates camera to center on user location ONLY ONCE
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
        
        // DEBUG: This code is for testing map location data
        //  print("Map centered on user at \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
}

#Preview {
    LostPetMapView()
}
