//
//  CommunityPostRow.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//

import SwiftUI

struct LostPetRow: View {
    let pet: LostPet

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            photoView // square thumbnail keeps list rows compact

            VStack(alignment: .leading, spacing: 6) {
                Text(pet.petName)
                    .font(.headline)

                Text(pet.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                if let date = pet.timestampDate {
                    Text("Updated \(formatted(date: date))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.vertical, 6)
    }

    private var photoView: some View {
        Group {
            if let url = pet.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 90, height: 90)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "photo")
                .foregroundColor(.white)
        }
    }

    private func formatted(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
