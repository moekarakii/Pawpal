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

    private var region: MKCoordinateRegion? {
        guard (-90.0...90.0).contains(pet.latitude),
              (-180.0...180.0).contains(pet.longitude) else {
            return nil
        }

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let url = pet.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color(.systemGray5)
                                ProgressView()
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(20)
                }

                infoCard // name + narrative copy styled like a hero card

                detailCard // metadata rows 

                if let date = pet.timestampDate {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reported")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(formatted(date: date))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(16)
                }

                mapCard // embedded map wrapped in same card treatment
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Pet Details")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(pet.petName)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(pet.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(20)
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Pet Details", systemImage: "info.circle")
                .font(.headline)
            infoRow(icon: "number", title: "Report ID", value: pet.id)
            infoRow(icon: "mappin.and.ellipse", title: "Coordinates",
                    value: "\(String(format: "%.4f", pet.latitude)), \(String(format: "%.4f", pet.longitude))")
            if pet.imageURL != nil {
                infoRow(icon: "photo.fill", title: "Photo", value: "Attached")
            } else {
                infoRow(icon: "photo", title: "Photo", value: "Not provided")
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(20)
    }

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Last Known Location", systemImage: "map")
                .font(.headline)
            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )) {
                Marker(pet.petName, coordinate: CLLocationCoordinate2D(latitude: pet.latitude, longitude: pet.longitude))
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(20)
    }

    // Shared rounded container styling so every section feels cohesive.
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
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
