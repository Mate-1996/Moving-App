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
    
    @State private var numberOfRooms = ""
    @State private var numberOfFragileItems = ""
    @State private var hasElevator = false
    @State private var floorLevel = ""
    @State private var specialInstructions = ""
    
    @State private var showConfirmation = false
    @State private var showValidationError = false
    @State private var errorMessage = ""
    
    @EnvironmentObject var authManager: AuthManager
    
    init(
            addressLine: String = "",
            city: String = "",
            province: String = "",
            postalCode: String = "",
            numberOfRooms: String = "",
            numberOfFragileItems: String = "",
            hasElevator: Bool = false,
            floorLevel: String = "",
            specialInstructions: String = ""
        ) {
            _addressLine = State(initialValue: addressLine)
            _city = State(initialValue: city)
            _province = State(initialValue: province)
            _postalCode = State(initialValue: postalCode)

            _numberOfRooms = State(initialValue: numberOfRooms)
            _numberOfFragileItems = State(initialValue: numberOfFragileItems)
            _hasElevator = State(initialValue: hasElevator)
            _floorLevel = State(initialValue: floorLevel)
            _specialInstructions = State(initialValue: specialInstructions)
        }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    if !addressLine.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(Color("goodPurple"))
                                Text("Moving From")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                            }
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
                        }
                        .padding(.horizontal, 20)
                    }
                    else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Your Address has not been input. Please enter your Address before continuing with the move request.")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }
                    

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
                                .autocapitalization(.words)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Elevator Available")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
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
                            
                            Text("Add any additional details here ")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
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
                        if validateInputs() {
                            showConfirmation = true
                        }
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
        .sheet(isPresented: $showConfirmation) {
            MoveRequestConfirmationView(
                addressLine: addressLine,
                city: city,
                province: province,
                postalCode: postalCode,
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
                        // Use cached user if already loaded
                        addressLine = addr.addressLine
                        city = addr.city
                        province = addr.province
                        postalCode = addr.postalCode
                    } else if let addr = await authManager.loadAddress() {
                        // Fetch from Firestore
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
            showValidationError = true
            return false
        }
        
        if floorLevel.isEmpty {
            errorMessage = "Please enter the floor level"
            showValidationError = true
            return false
        }
        
        if addressLine.isEmpty || province.isEmpty || postalCode.isEmpty {
            errorMessage = "Please enter your address completely before submitting a move request."
            showValidationError = true
            return false
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
