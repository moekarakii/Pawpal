//
//  LostPetReportView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/05/25.
//

import SwiftUI
import MapKit
import Firebase
import CoreLocation
import FirebaseFirestore
import UIKit

enum Validators {
    static func isValidPetName(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count >= 2 && t.count <= 40
    }
    static func isValidDescription(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.count >= 10 && t.count <= 500
    }
    static func isValidCoordinate(lat: Double, lon: Double) -> Bool {
        (-90.0...90.0).contains(lat) && (-180.0...180.0).contains(lon)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LostPetReportView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var completerDelegateWrapper = CompleterDelegateWrapper()
    @EnvironmentObject var authVM: AuthViewModel
    @State private var petName = ""
    @State private var petDescription = ""
    @State private var pinCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchQuery = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var hasManuallySelectedLocation = false

    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSubmitting: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("Pet Name", text: $petName)
                    .textFieldStyle(.roundedBorder)

                TextField("Description", text: $petDescription)
                    .textFieldStyle(.roundedBorder)

                Text("Tap to move the red pin to the last seen location")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Search for a place...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchQuery) { newValue in
                        print("🔤 User typed: \(newValue)")
                        searchCompleter.queryFragment = newValue
                    }
                    .onAppear {
                        print("🧩 Setting completer delegate")
                        searchCompleter.delegate = completerDelegateWrapper
                        searchCompleter.resultTypes = .address
                    }

                if !completerDelegateWrapper.results.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(completerDelegateWrapper.results) { result in
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .font(.body)
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                                selectSearchCompletion(result.completion)
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                }

                Map(position: $cameraPosition) {
                    Marker(petName.isEmpty ? "Last Seen" : petName, coordinate: pinCoordinate)
                }
                .frame(height: 250)
                .onAppear {
                    if let userLocation = locationManager.location {
                        setCameraAndPin(to: userLocation.coordinate)
                    }
                }
                .onReceive(locationManager.$location) { _ in
                    // is pinging every frame
//                    print("📍 Location changed to: \(String(describing: locationManager.location?.coordinate))")
                    if !hasManuallySelectedLocation, let coord = locationManager.location?.coordinate {
                        setCameraAndPin(to: coord)
                    }
                }

                Button("Submit Report") {
                    submitLostPetReport()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Report Lost Pet")

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Report Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func submitLostPetReport() {
        let lat = pinCoordinate.latitude
        let lon = pinCoordinate.longitude

        guard Validators.isValidPetName(petName) else {
            alertMessage = "Please enter a valid pet name (2–40 characters)."
            showAlert = true; return
        }
        guard Validators.isValidDescription(petDescription) else {
            alertMessage = "Please enter a valid description (10–500 characters)."
            showAlert = true; return
        }
        guard Validators.isValidCoordinate(lat: lat, lon: lon) else {
            alertMessage = "Please select a valid location on the map."
            showAlert = true; return
        }

        isSubmitting = true
        
        let data: [String: Any] = [
            FS.LostPets.petName: petName,
            FS.LostPets.description: petDescription,
            FS.LostPets.lat: pinCoordinate.latitude,
            FS.LostPets.lng: pinCoordinate.longitude,
            FS.LostPets.timestamp: FieldValue.serverTimestamp(),
            
            // Attempt to connect reports with user ID, Also accounts for old reports not having userId attac
            "userId": authVM.user?.uid ?? ""
        ]

        Firestore.firestore().collection(FS.LostPets.collection).addDocument(data: data) { error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Failed to submit: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    alertMessage = "Lost pet report submitted successfully."
                    showAlert = true
                    petName = ""
                    petDescription = ""
                    hasManuallySelectedLocation = false
                }
            }
        }
    }

    private func setCameraAndPin(to coord: CLLocationCoordinate2D) {
        pinCoordinate = coord
        cameraPosition = .region(
            MKCoordinateRegion(center: coord,
                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        )
    }
    private func selectSearchCompletion(_ completion: MKLocalSearchCompletion) {
        hasManuallySelectedLocation = true

        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                setCameraAndPin(to: coordinate)
                searchQuery = completion.title

                // 👇 Delay hiding suggestions to fix render glitch
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    completerDelegateWrapper.results = []
                }
            } else {
                print("❌ Could not resolve selected location")
            }
        }
    }
}

#Preview {
    LostPetReportView()
}
