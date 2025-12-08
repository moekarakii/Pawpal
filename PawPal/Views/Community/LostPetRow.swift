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
        HStack(alignment: .top, spacing: 16) {
            // Pet Icon / Avatar
            ZStack {
                Circle()
                    .fill(Color.theme.babyBlue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.theme.babyBlue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pet.petName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let timestamp = pet.timestamp {
                        Text(timeAgoString(from: timestamp))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Text(pet.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.8))
                    
                    Text("Tap to see location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
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