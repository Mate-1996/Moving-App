//
//  OrganizeMoveView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct OrganizeMoveView: View {

    @State var addressLine: String = ""
    @State var city: String = ""
    @State var province: String = ""
    @State var postalCode: String = ""

    @State private var destAddressLine = ""
    @State private var destCity = ""
    @State private var destProvince = ""
    @State private var destPostalCode = ""

    @State private var numberOfRooms = ""
    @State private var numberOfFragileItems = ""
    @State private var hasElevator = false
    @State private var floorLevel = ""
    @State private var specialInstructions = ""

    @State private var showPickupMapPicker = false
    @State private var showDestinationMapPicker = false
    @State private var showConfirmation = false
    @State private var showValidationError = false
    @State private var errorMessage = ""

    @EnvironmentObject var authManager: AuthManager

    init(
        addressLine: String = "",
        city: String = "",
        province: String = "",
        postalCode:  String = ""
    ) {
        _addressLine = State(initialValue: addressLine)
        _city = State(initialValue: city)
        _province = State(initialValue: province)
        _postalCode = State(initialValue: postalCode)
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Moving From")
                                .font(.system(size: 16, weight: .semibold))
                        }

                        if !addressLine.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(addressLine)
                                Text("\(city), \(province) \(postalCode)")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        } else {
                            HStack {
                                Text("No pickup address set.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: { showPickupMapPicker = true }) {
                            HStack {
                                Text("Change on map")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(Color("goodPurple"))
                            .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Moving To")
                                .font(.system(size: 16, weight: .semibold))
                        }

                        if !destAddressLine.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(destAddressLine)
                                Text("\(destCity), \(destProvince) \(destPostalCode)")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        } else {
                            Text("No destination selected yet.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }

                        Button(action: { showDestinationMapPicker = true }) {
                            HStack {
                                Text(destAddressLine.isEmpty ? "Pick destination on map" : "Change on map")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Rooms")
                                .font(.system(size: 14, weight: .semibold))
                            TextField("Enter number of rooms", text: $numberOfRooms)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Fragile Items")
                                .font(.system(size: 14, weight: .semibold))
                            TextField("Enter number of fragile items", text: $numberOfFragileItems)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Floor Level")
                                .font(.system(size: 14, weight: .semibold))
                            TextField("Enter your floor level", text: $floorLevel)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Elevator Available")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Is there an elevator?")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: $hasElevator)
                                .labelsHidden()
                                .tint(Color("goodPurple"))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Special Instructions (Optional)")
                                .font(.system(size: 14, weight: .semibold))
                            TextEditor(text: $specialInstructions)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            Text("Add any additional details here")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)

                    if showValidationError {
                        HStack {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }

                    Button(action: {
                        if validateInputs() { showConfirmation = true }
                    }) {
                        Text("Submit Move Request")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("goodPurple"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Spacer(minLength: 30)
                }
            }
        }
        .navigationTitle("Move Details")
        .navigationBarTitleDisplayMode(.inline)
        
        .sheet(isPresented: $showPickupMapPicker) {
            MapPickerView { address in
                addressLine = address.addressLine
                city = address.city
                province = address.province
                postalCode = address.postalCode
            }
        }
       
        .sheet(isPresented: $showDestinationMapPicker) {
            MapPickerView { address in
                destAddressLine = address.addressLine
                destCity = address.city
                destProvince = address.province
                destPostalCode = address.postalCode
            }
        }
        .sheet(isPresented: $showConfirmation) {
            MoveRequestConfirmationView(
                pickupAddress: Address(
                    addressLine: addressLine,
                    city: city,
                    province: province,
                    postalCode: postalCode
                ),
                destinationAddress: Address(
                    addressLine: destAddressLine,
                    city: destCity,
                    province: destProvince,
                    postalCode: destPostalCode
                ),
                numberOfRooms: numberOfRooms,
                numberOfFragileItems: numberOfFragileItems,
                floorLevel: floorLevel,
                hasElevator: hasElevator,
                specialInstructions: specialInstructions
            )
        }
        .task {
            if addressLine.isEmpty {
                if let addr = authManager.user?.address {
                    addressLine = addr.addressLine
                    city = addr.city
                    province = addr.province
                    postalCode = addr.postalCode
                } else if let addr = await authManager.loadAddress() {
                    addressLine = addr.addressLine
                    city = addr.city
                    province = addr.province
                    postalCode = addr.postalCode
                }
            }
        }
    }

    func validateInputs() -> Bool {
        showValidationError = false
        errorMessage = ""

        if numberOfRooms.isEmpty {
            errorMessage = "Please enter the number of rooms"
            showValidationError = true; return false
        }
        if floorLevel.isEmpty {
            errorMessage = "Please enter the floor level"
            showValidationError = true; return false
        }
        if addressLine.isEmpty || province.isEmpty || postalCode.isEmpty {
            errorMessage = "Please enter your pickup address before submitting."
            showValidationError = true; return false
        }
        if destAddressLine.isEmpty {
            errorMessage = "Please select a destination address on the map."
            showValidationError = true; return false
        }
        return true
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
    }
}
