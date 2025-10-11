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

    @State private var petName = ""
    @State private var petDescription = ""
    @State private var pinCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchQuery = ""
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var hasManuallySelectedLocation = false

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
                    .onChange(of: searchQuery) {
                        print("🔤 User typed: \(searchQuery)")
                        searchCompleter.queryFragment = searchQuery
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
                .onChange(of: locationManager.location) {
                    print("📍 Location changed to: \(String(describing: locationManager.location?.coordinate))")
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
    }

    private func submitLostPetReport() {
        let lat = pinCoordinate.latitude
        let lon = pinCoordinate.longitude

        guard Validators.isValidPetName(petName) else {
            print("Invalid pet name (2–40 chars)"); return
        }
        guard Validators.isValidDescription(petDescription) else {
            print("Invalid description (10–500 chars)"); return
        }
        guard Validators.isValidCoordinate(lat: lat, lon: lon) else {
            print("Invalid coordinates"); return
        }

        let data: [String: Any] = [
            FS.LostPets.petName: petName,
            FS.LostPets.description: petDescription,
            FS.LostPets.lat: pinCoordinate.latitude,
            FS.LostPets.lng: pinCoordinate.longitude,
            FS.LostPets.timestamp: FieldValue.serverTimestamp()
        ]

        Firestore.firestore().collection(FS.LostPets.collection).addDocument(data: data) { error in
            if let error = error {
                print("Error submitting report: \(error.localizedDescription)")
            } else {
                print("✅ Lost pet report submitted successfully.")
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
