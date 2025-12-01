//
//  LostPet.swift
//  PawPal
//
//  Created by Juan Zavala  on 8/20/25.
//

import Foundation
import SwiftUI

struct LostPet: Identifiable, Codable {
    var id: String
    var petName: String
    var description: String
    var latitude: Double
    var longitude: Double
    /// Optional Storage URL used for the feed thumbnail + detail hero image.
    var photoURL: String? = nil
    var timestamp: Date? = nil

    var timestampDate: Date? {
        return timestamp
    }

    var imageURL: URL? {
        guard let photoURL, let url = URL(string: photoURL) else { return nil }
        return url
    }
}
