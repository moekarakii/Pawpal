//
//  LostPetDetailView.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/17/25.
//

import SwiftUI
import MapKit

struct LostPetDetailView: View {
    let pet: LostPet

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(pet.petName)
                    .font(.largeTitle)
                    .bold()

                Text(pet.description)
                    .font(.body)

                if let date = pet.timestampDate {
                    Text("Reported on \(formatted(date: date))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )) {
                    Marker(pet.petName, coordinate: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude))
                }
                .frame(height: 250)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Pet Details")
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    LostPetDetailView(pet: LostPet(
        id: "1",
        petName: "Bella",
        description: "Last seen near Elm Street.",
        latitude: 38.5449,
        longitude: -121.7405,
        timestamp: Date()
    ))
}
