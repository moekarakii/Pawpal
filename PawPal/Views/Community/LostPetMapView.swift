//
//  LostPetMapView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

import Firebase
import MapKit
import SwiftUI
import UserNotifications

struct LostPetMapView: View {

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authVM: AuthViewModel   // now provides lost pet data globally

    // This starts our default location centered on San Francisco
    // Want to replace it with the user's location data if available
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 37.7749,
                longitude: -122.4194
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    // Used to confirm when we've successfully centered on the user
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            // Map View
            Map(position: $cameraPosition) {

                // Display one marker per lost pet document
                // Data source now comes directly from AuthViewModel (global listener)
                ForEach(authVM.lostPets) { pet in
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
                    Annotation(
                        "You are here",
                        coordinate: userLocation.coordinate
                    ) {
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

            // Empty state message
            if authVM.lostPets.isEmpty {
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
        }
        // Re-center camera when user location updates
        .onReceive(locationManager.$location) { newLocation in
            if let loc = newLocation {
                moveCameraToUserLocation(loc)
            }
        }
    }

    // ----------------------------------------------------------------------
    // MAP CAMERA MOVEMENT + LOCATION HANDLING
    // ----------------------------------------------------------------------

    private func setupUserLocation() {
        if let userLocation = locationManager.location {
            moveCameraToUserLocation(userLocation)
        } else {
            // If we don't yet have a location, wait briefly then check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let userLocation = locationManager.location {
                    moveCameraToUserLocation(userLocation)
                }
            }
        }
    }

    // Updates camera to center on user location ONLY ONCE
    private func moveCameraToUserLocation(_ location: CLLocation) {
        guard !hasCenteredOnUser else { return }
        hasCenteredOnUser = true

        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
        )
    }
}

#Preview {
    LostPetMapView()
        .environmentObject(LocationManager())
        .environmentObject(AuthViewModel())
}
