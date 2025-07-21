//
//  MapViewController.swift
//  PawPal
//
//  Created by Khang Nguyen on 10/12/24.
//  Modifed by Moe Karaki on 7/18/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        Map(coordinateRegion: $region)
            .ignoresSafeArea()
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
    }
}
