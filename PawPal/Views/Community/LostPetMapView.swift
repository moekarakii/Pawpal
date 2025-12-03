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

    // array of lost pets fetched from data base (init)
    @State private var lostPets: [LostPet] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // A shared Firestore reference to make it more intuitive for reuse
    private let db = Firestore.firestore()

    // Keep a handle to the Firestore listener so we don't accidentally attach multiple listeners
    @State private var listener: ListenerRegistration?

    // Used to confirm when we've successfully centered on the user
    @State private var hasCenteredOnUser = false

    // Track which pets we've already notified about (prevents duplicate alerts)
    @State private var notifiedPetIds: Set<String> = []

    // How far away (in miles) triggers a proximity alert
    private let alertRadiusMiles: Double = 5.0

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
        .onDisappear {
            stopListeningForLostPets()
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }

        // When user’s location changes, re-run proximity check
        .onReceive(locationManager.$location) { newLocation in
            if let userLocation = newLocation, !lostPets.isEmpty {
                checkProximity(pets: lostPets, userLocation: userLocation)
            }
        }
    }

    // Fetches lost pets dynamically with real-time updates
    private func startListeningForLostPets() {
        // Avoid attaching multiple listeners if view appears more than once
        guard listener == nil else { return }

        isLoading = true

        listener = db.collection(FS.LostPets.collection).addSnapshotListener {
            snapshot,
            error in
            isLoading = false

            if let error = error {
                alertMessage =
                    "Failed to load lost pets: \(error.localizedDescription)"
                showAlert = true
                return
            }

            guard let documents = snapshot?.documents else {
                self.lostPets = []
                return
            }

            // Store old list for comparing timestamps
            let previousPets = self.lostPets

            // Convert Firestore data into LostPet structs
            self.lostPets = documents.compactMap { doc in
                let data = doc.data()

                guard
                    let name = data[FS.LostPets.petName] as? String,
                    let desc = data[FS.LostPets.description] as? String,
                    let lat = data[FS.LostPets.lat] as? Double,
                    let lng = data[FS.LostPets.lng] as? Double
                else { return nil }

                let timestamp = (data[FS.LostPets.timestamp] as? Timestamp)?
                    .dateValue()

                return LostPet(
                    id: doc.documentID,
                    petName: name,
                    description: desc,
                    latitude: lat,
                    longitude: lng,
                    timestamp: timestamp,
                    userId: data["userId"] as? String
                )
            }

            // Only proximity-check newly created pets based on timestamps
            if let userLocation = locationManager.location {
                let newPets = petsReportedRecently(
                    newList: self.lostPets,
                    oldList: previousPets
                )
                checkProximity(pets: newPets, userLocation: userLocation)
            }
        }
    }

    // Stops listening to Firestore updates when the view disappears
    private func stopListeningForLostPets() {
        listener?.remove()
        listener = nil
    }

    // Returns only pets with timestamps newer than the old list
    // This avoids notifications for old reports (when snapshot refreshes)
    private func petsReportedRecently(newList: [LostPet], oldList: [LostPet])
        -> [LostPet]
    {
        let oldIds = Set(oldList.map { $0.id })

        // Only new IDs
        let newlyAdded = newList.filter { !oldIds.contains($0.id) }

        // Enforce a timestamp freshness window (3 minutes)
        let freshnessWindow: TimeInterval = 180
        let cutoff = Date().addingTimeInterval(-freshnessWindow)

        return newlyAdded.filter { pet in
            if let ts = pet.timestamp {
                return ts >= cutoff
            }
            return false
        }
    }

    // Checks a new set of pets against the user's current location
    // and sends an alert if they fall within the radius
    // Checks a new set of pets against the user's current location
    // and sends an alert if they fall within the radius
    func checkProximity(pets: [LostPet], userLocation: CLLocation) {

        for pet in pets {

            // Skip pets we've already notified about
            if notifiedPetIds.contains(pet.id) {
                continue
            }

            // Skip pets without timestamps
            guard let timestamp = pet.timestamp else {
                continue
            }

            // Only consider timestamp-fresh pets (matches fresh filter)
            let freshnessWindow: TimeInterval = 180
            let cutoff = Date().addingTimeInterval(-freshnessWindow)
            if timestamp < cutoff {

                continue
            }

            let petLocation = CLLocation(
                latitude: pet.latitude,
                longitude: pet.longitude
            )

            // Distance calculations
            let distanceInMeters = petLocation.distance(from: userLocation)
            let distanceInMiles = distanceInMeters / 1609.34

            if distanceInMiles <= alertRadiusMiles {
                sendProximityAlert(for: pet)
                notifiedPetIds.insert(pet.id)
            }
        }
    }

    private func sendProximityAlert(for pet: LostPet) {
        let content = UNMutableNotificationContent()
        content.title = "Nearby Lost Pet"
        content.body =
            "\(pet.petName) was reported within \(Int(alertRadiusMiles)) miles of you."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func setupUserLocation() {
        if let userLocation = locationManager.location {
            moveCameraToUserLocation(userLocation)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let userLocation = locationManager.location {
                    moveCameraToUserLocation(userLocation)
                }
            }
        }
    }

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
}
