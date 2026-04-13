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

    @State private var selectedTab = 0

    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isGeocoding = false
    @State private var detectedAddress: Address?
    @State private var mapError: String?
    @State private var geocodeTask: DispatchWorkItem?
    @StateObject private var locationManager = LocationManager()

    @State private var manualLine = ""
    @State private var manualCity = ""
    @State private var manualProvince = ""
    @State private var manualPostal = ""
    @State private var manualError = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Picker("Mode", selection: $selectedTab) {
                    Label("Map", systemImage: "map").tag(0)
                    Label("Manual", systemImage: "keyboard").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                if selectedTab == 0 {
                    mapTab
                } else {
                    manualTab
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if selectedTab == 0 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm") { confirmMapAddress() }
                            .bold()
                            .disabled(detectedAddress == nil || isGeocoding)
                    }
                }
            }
            .onReceive(locationManager.$userLocation) { coord in
                if let coord {
                    withAnimation { region.center = coord }
                    geocodeCurrentCenter()
                }
            }
        }
    }


    private var mapTab: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region)
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: region.center.latitude)  { geocodeCurrentCenter() }
                .onChange(of: region.center.longitude) { geocodeCurrentCenter() }

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color("goodPurple"))
                        .frame(width: 38, height: 38)
                        .shadow(color: Color("goodPurple").opacity(0.45), radius: 10, y: 5)
                    Image(systemName: "mappin")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                }
                Rectangle()
                    .fill(Color("goodPurple"))
                    .frame(width: 3, height: 16)
                Ellipse()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 10, height: 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: -32)
            .allowsHitTesting(false)

            addressCard
        }
    }

    private var addressCard: some View {
        Group {
            if isGeocoding {
                HStack(spacing: 12) {
                    ProgressView().tint(Color("goodPurple"))
                    Text("Finding address")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)

            } else if let addr = detectedAddress {
                HStack(spacing: 14) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("goodPurple"))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(addr.addressLine)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text("\(addr.city), \(addr.province)  \(addr.postalCode)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(16)

            } else if let err = mapError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                    Text(err).font(.system(size: 13)).foregroundColor(.secondary)
                }
                .padding(16)

            } else {
                HStack(spacing: 10) {
                    Image(systemName: "hand.draw").foregroundColor(.secondary)
                    Text("Drag the map to pick a location")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.13), radius: 20, y: -6)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isGeocoding)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: detectedAddress?.addressLine)
    }


    private var manualTab: some View {
        ScrollView {
            VStack(spacing: 20) {

                VStack(spacing: 4) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 36))
                        .foregroundColor(Color("goodPurple"))
                    Text("Enter address manually")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 4)

                VStack(spacing: 14) {
                    ManualField(label: "Street Address", placeholder: "123 Main St",
                                text: $manualLine, contentType: .streetAddressLine1)
                    ManualField(label: "City", placeholder: "Montreal",
                                text: $manualCity, contentType: .addressCity)
                    ManualField(label: "Province", placeholder: "Quebec",
                                text: $manualProvince, contentType: .addressState)
                    ManualField(label: "Postal Code", placeholder: "H1A 1A1",
                                text: $manualPostal, contentType: .postalCode, allCaps: true)
                }

                if !manualError.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                        Text(manualError).font(.caption).foregroundColor(.red)
                    }
                }

                Button(action: confirmManual) {
                    Text("Use This Address")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("goodPurple"))
                        .cornerRadius(14)
                }
                .padding(.top, 4)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }


    private func geocodeCurrentCenter() {
        geocodeTask?.cancel()
        mapError = nil

        let work = DispatchWorkItem {
            isGeocoding = true
            let loc = CLLocation(latitude: region.center.latitude,
                                 longitude: region.center.longitude)
            CLGeocoder().reverseGeocodeLocation(loc) { placemarks, _ in
                isGeocoding = false
                if let p = placemarks?.first {
                    let line = [p.subThoroughfare, p.thoroughfare]
                        .compactMap { $0 }.joined(separator: " ")
                    detectedAddress = Address(
                        addressLine: line.isEmpty ? "Unknown street" : line,
                        city:        p.locality ?? p.subLocality ?? "",
                        province:    p.administrativeArea ?? "",
                        postalCode:  p.postalCode ?? ""
                    )
                } else {
                    detectedAddress = nil
                    mapError = "No address found here."
                }
            }
        }
        geocodeTask = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: work)
    }

    private func confirmMapAddress() {
        guard let addr = detectedAddress else { return }
        onSelect(addr); dismiss()
    }

    private func confirmManual() {
        manualError = ""
        if manualLine.trimmingCharacters(in: .whitespaces).isEmpty  { manualError = "Please enter a street address."; return }
        if manualCity.trimmingCharacters(in: .whitespaces).isEmpty   { manualError = "Please enter a city."; return }
        if manualProvince.trimmingCharacters(in: .whitespaces).isEmpty { manualError = "Please enter a province."; return }
        if manualPostal.trimmingCharacters(in: .whitespaces).isEmpty  { manualError = "Please enter a postal code."; return }
        onSelect(Address(addressLine: manualLine, city: manualCity,
                         province: manualProvince, postalCode: manualPostal))
        dismiss()
    }
}


private struct ManualField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var allCaps = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textContentType(contentType)
                .autocapitalization(allCaps ? .allCharacters : .words)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first?.coordinate
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location: \(error.localizedDescription)")
    }
}
