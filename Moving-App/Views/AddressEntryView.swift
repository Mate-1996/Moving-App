//
//  AddressEntryView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct AddressEntryView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var addressLine = ""
    @State private var city = ""
    @State private var province = ""
    @State private var postalCode = ""

    @State private var showMapPicker = false
    @State private var showValidationError  = false
    @State private var errorMessage = ""
    @State private var navigateToOrganizeMove = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {

                    VStack(spacing: 10) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("goodPurple"))
                            .padding(.top, 20)

                        Text("Fill in your address")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 10)

                    Button(action: { showMapPicker = true }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Pick location on map")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("goodPurple"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 20) {
                        AddressField(label: "Street Address",
                                     placeholder: "Street name",
                                     text: $addressLine,
                                     contentType: .streetAddressLine1)

                        AddressField(label: "City",
                                     placeholder: "City name",
                                     text: $city,
                                     contentType: .addressCity)

                        AddressField(label: "Province",
                                     placeholder: "Province name",
                                     text: $province,
                                     contentType: .addressState)

                        AddressField(label: "Postal Code",
                                     placeholder: "Your postal code",
                                     text: $postalCode,
                                     contentType: .postalCode,
                                     allCaps: true)
                    }
                    .padding(.horizontal, 20)

                    if showValidationError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }

                    Button(action: validateAndContinue) {
                        Text("Continue")
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
        .navigationTitle("Address Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMapPicker) {
            MapPickerView { address in
                addressLine = address.addressLine
                city = address.city
                province = address.province
                postalCode = address.postalCode
            }
        }
        .task {
            if let addr = await authManager.loadAddress() {
                addressLine = addr.addressLine
                city = addr.city
                province = addr.province
                postalCode = addr.postalCode
            }
        }
    }

    func validateAndContinue() {
        showValidationError = false
        errorMessage = ""

        if addressLine.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a street address"; showValidationError = true; return
        }
        if city.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a city"; showValidationError = true; return
        }
        if province.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a province"; showValidationError = true; return
        }
        if postalCode.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a postal code"; showValidationError = true; return
        }

        let addr = Address(addressLine: addressLine, city: city,
                           province: province, postalCode: postalCode)
        Task {
            await authManager.saveAddress(addr)
            if let msg = authManager.authError {
                errorMessage = msg; showValidationError = true
            } else {
                dismiss()
            }
        }
    }
}


private struct AddressField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var contentType: UITextContentType? = nil
    var allCaps = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .textContentType(contentType)
                .autocapitalization(allCaps ? .allCharacters : .words)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView { AddressEntryView() }
}
