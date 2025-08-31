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
        VStack(alignment: .leading, spacing: 8) {
            Text(pet.petName)
                .font(.headline)

            Text(pet.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
        .padding(.vertical, 4)
    }
}
