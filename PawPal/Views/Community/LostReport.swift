import Foundation
import CoreLocation
import FirebaseFirestore

/// Canonical representation of what we persist in Firestore's `lost_pets` collection.
struct LostReport: Identifiable {
    var id: String
    var reporterId: String
    var petName: String
    var animalType: String
    var description: String
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var photoURL: String?
    var status: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(id: String = UUID().uuidString,
         reporterId: String,
         petName: String,
         animalType: String,
         description: String,
         timestamp: Date = Date(),
         latitude: Double,
         longitude: Double,
         photoURL: String? = nil,
         status: String = "active") {
        self.id = id
        self.reporterId = reporterId
        self.petName = petName
        self.animalType = animalType
        self.description = description
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = photoURL
        self.status = status
    }

    init?(id: String, data: [String: Any]) {
          guard let reporterId = data["reporterId"] as? String,
              let animalType = data["animalType"] as? String,
              let description = data["description"] as? String,
              let ts = data["timestamp"] as? Timestamp,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              let status = data["status"] as? String
        else { return nil }

        self.id = id
        self.reporterId = reporterId
                // Older documents may not include petName, so we fall back gracefully.
                self.petName = data["petName"] as? String ?? "Unknown Pet"
        self.animalType = animalType
        self.description = description
        self.timestamp = ts.dateValue()
        self.latitude = latitude
        self.longitude = longitude
        self.photoURL = data["photoURL"] as? String
        self.status = status
    }
}
