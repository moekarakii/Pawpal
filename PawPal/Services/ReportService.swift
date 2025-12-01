import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

/// Encapsulates Firestore + Storage interactions for lost pet reports.
class ReportService: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func publish(report: LostReport, imageData: Data?, completion: @escaping (Result<Void, Error>) -> Void) {
        var docData: [String: Any] = [
            "reporterId": report.reporterId,
            "petName": report.petName,
            "animalType": report.animalType,
            "description": report.description,
            "timestamp": Timestamp(date: report.timestamp),
            "latitude": report.latitude,
            "longitude": report.longitude,
            "status": report.status
        ]

        let id = report.id

        if let data = imageData {
            let ref = storage.reference().child("lost_pets/\(id).jpg")
            _ = ref.putData(data, metadata: nil) { metadata, error in
                if let error = error { completion(.failure(error)); return }
                ref.downloadURL { url, error in
                    if let error = error { completion(.failure(error)); return }
                    if let url = url {
                        docData["photoURL"] = url.absoluteString
                    }
                    self.db.collection("lost_pets").document(id).setData(docData) { err in
                        if let err = err { completion(.failure(err)); return }
                        completion(.success(()))
                    }
                }
            }
        } else {
            db.collection("lost_pets").document(id).setData(docData) { err in
                if let err = err { completion(.failure(err)); return }
                completion(.success(()))
            }
        }
    }

    func queryNearby(center: CLLocationCoordinate2D, radiusMeters: Double = 1609, completion: @escaping ([LostReport]) -> Void) {
        let lat = center.latitude
        let lon = center.longitude
        let latDelta = radiusMeters / 111000.0
        let lonDelta = radiusMeters / (111000.0 * cos(lat * .pi / 180.0))
        let latMin = lat - latDelta, latMax = lat + latDelta

        db.collection("lost_pets")
            .whereField("latitude", isGreaterThanOrEqualTo: latMin)
            .whereField("latitude", isLessThanOrEqualTo: latMax)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { completion([]); return }
                var results = [LostReport]()
                let centerLoc = CLLocation(latitude: lat, longitude: lon)
                for doc in docs {
                    let data = doc.data()
                    var mapped = data
                    // Legacy documents stored `lat/lng`, newer ones store `latitude/longitude`.
                    if mapped["latitude"] == nil, let lat = data["lat"] as? Double {
                        mapped["latitude"] = lat
                    }
                    if mapped["longitude"] == nil, let lng = data["lng"] as? Double {
                        mapped["longitude"] = lng
                    }
                    if let r = LostReport(id: doc.documentID, data: mapped) {
                        let reportLoc = CLLocation(latitude: r.latitude, longitude: r.longitude)
                        let dist = centerLoc.distance(from: reportLoc)
                        if dist <= radiusMeters {
                            results.append(r)
                        }
                    }
                }
                completion(results)
            }
    }
}
