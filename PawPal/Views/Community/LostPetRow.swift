//
//  LostPetRow.swift
//  PawPal
//
//  Created by GitHub Copilot on 11/23/25.
//

import SwiftUI

struct LostPetRow: View {
    let pet: LostPet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.petName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(pet.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if let timestamp = pet.timestamp {
                        Text("Reported \(timeAgoString(from: timestamp))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            
            Divider()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if days > 0 {
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    VStack {
        LostPetRow(pet: LostPet(
            id: "1",
            petName: "Bella",
            description: "Golden retriever, very friendly. Last seen wearing a red collar near the park.",
            latitude: 37.7749,
            longitude: -122.4194,
            timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
        ))
        
        LostPetRow(pet: LostPet(
            id: "2",
            petName: "Max",
            description: "Small black and white cat, responds to his name.",
            latitude: 37.7849,
            longitude: -122.4094,
            timestamp: Date().addingTimeInterval(-86400) // 1 day ago
        ))
    }
}