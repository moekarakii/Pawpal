//
//  ProfileViewController.swift
//  PawPal
//
//  Created by Hieu Hoang on 12/15/24.
//  Modified by Moe Karaki on 7/18/25.
//
import SwiftUI

struct PetProfile {
    var image: UIImage?
    var name: String
    var type: String
    var age: String
    var characteristics: [String]
    var description: String
}

struct ProfileView: View {
    let petProfile: PetProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = petProfile.image {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 150, height: 150)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                }

                Text(petProfile.name)
                    .font(.title)
                    .fontWeight(.bold)

                Text("Type: \(petProfile.type)")
                    .font(.subheadline)

                Text("Age: \(petProfile.age)")
                    .font(.subheadline)

                // 🧷 Characteristics
                if !petProfile.characteristics.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Characteristics:")
                            .font(.headline)

                        FlowLayout(alignment: .leading, spacing: 8) {
                            ForEach(petProfile.characteristics, id: \.self) { trait in
                                Text(trait)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.teal)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                Text(petProfile.description)
                    .font(.body)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Pet Profile")
    }
}


