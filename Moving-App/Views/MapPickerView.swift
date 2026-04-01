//
//  MapPickerView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-03-28.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

struct MapPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let onSelect: (Address) -> Void
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    @State private var isGeocoding  = false
    @State private var errorMessage: String?

    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region)
                    .ignoresSafeArea()
                    .onReceive(locationManager.$userLocation) { coord in
                        if let coord {
                            region.center = coord
                        }
                    }

                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color("goodPurple"))
                        .shadow(radius: 4)

                    Ellipse()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 12, height: 4)
                }
                .offset(y: -24)

                VStack {
                    Spacer()
                    if isGeocoding {
                        Label("Finding address", systemImage: "location.magnifyingglass")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    } else if let err = errorMessage {
                        Label(err, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") { reverseGeocode() }
                        .bold()
                        .disabled(isGeocoding)
                }
            }
        }
    }


    private func reverseGeocode() {
        isGeocoding = true
        errorMessage = nil

        let geocoder  = CLGeocoder()
        let location  = CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isGeocoding = false

            if let error {
                errorMessage = error.localizedDescription
                return
            }

            guard let p = placemarks?.first else {
                errorMessage = "Could not find an address here"
                return
            }

            let streetNumber = p.subThoroughfare ?? ""
            let streetName = p.thoroughfare ?? ""
            let addressLine = [streetNumber, streetName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")

            let address = Address(
                addressLine: addressLine.isEmpty ? "Unknown street" : addressLine,
                city : p.locality ?? p.subLocality ?? "",
                province : p.administrativeArea ?? "",
                postalCode : p.postalCode ?? ""
            )

            onSelect(address)
            dismiss()
        }
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D? = nil

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
