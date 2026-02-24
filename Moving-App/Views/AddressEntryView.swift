//
//  AddressEntryView.swift
//  Moving-App
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct AddressEntryView: View {
    @State private var addressLine = ""
    @State private var city = ""
    @State private var province = ""
    @State private var postalCode = ""
    

    @State private var showValidationError = false
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
                    .padding(.bottom, 20)
                    

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Street Address")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Stree name", text: $addressLine)
                                .textContentType(.streetAddressLine1)
                                .autocapitalization(.words)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("City")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("City name", text: $city)
                                .textContentType(.addressCity)
                                .autocapitalization(.words)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Province")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Province name", text: $province)
                                .textContentType(.addressState)
                                .autocapitalization(.words)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Postal Code")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Your postal code here", text: $postalCode)
                                .textContentType(.postalCode)
                                .autocapitalization(.allCharacters)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
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
                    
                    Button(action: {
                        validateAndContinue()
                    }) {
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
        .navigationDestination(isPresented: $navigateToOrganizeMove) {
            OrganizeMoveView(
                addressLine: addressLine,
                city: city,
                province: province,
                postalCode: postalCode
            )
        }
    }
    
    func validateAndContinue() {
        showValidationError = false
        errorMessage = ""
        
        if addressLine.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a street address"
            showValidationError = true
            return
        }
        
        if city.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a city"
            showValidationError = true
            return
        }
        
        if province.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a province"
            showValidationError = true
            return
        }
        
        if postalCode.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a postal code"
            showValidationError = true
            return
        }
        
        
        navigateToOrganizeMove = true
    }
}

#Preview {
    NavigationView {
        AddressEntryView()
    }
}
