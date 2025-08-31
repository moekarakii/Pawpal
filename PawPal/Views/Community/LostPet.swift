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
    var timestamp: Date? = nil

    var timestampDate: Date? {
        return timestamp
    }
}
