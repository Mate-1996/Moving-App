//
//  MoveRequestConfirmationView.swift
//  Moving-App
//
//  Created by user285578 on 2/25/26.
//

import SwiftUI

struct MoveRequestConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let addressLine: String
    let city: String
    let province: String
    let postalCode: String
    let numberOfRooms: String
    let numberOfFragileItems: String
    let floorLevel: String
    let hasElevator: Bool
    let specialInstructions: String
    
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        if showSuccess {
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.green)
                                
                                Text("Request Sent!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("The admin will review your move request and contact you soon to discuss details and pricing.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 60)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color("goodPurple"))
                                    .padding(.top, 40)
                                
                                Text("Review Your Request")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                Text("After submitting, move request details cannot be changed, any further info will be discussed by the mover in person.")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            
                           
                            VStack(alignment: .leading, spacing: 15) {
                               
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Address")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Text(addressLine)
                                        .foregroundColor(.black)
                                    Text("\(city), \(province) \(postalCode)")
                                        .foregroundColor(.black)
                                }
                                
                                Divider()
                                
                                DetailRow(label: "Number of Rooms", value: numberOfRooms)
                                Divider()
                                
                                DetailRow(label: "Fragile Items", value: numberOfFragileItems.isEmpty ? "None" : numberOfFragileItems)
                                Divider()
                                
                                DetailRow(label: "Floor Level", value: floorLevel)
                                Divider()
                                
                                DetailRow(label: "Elevator Available", value: hasElevator ? "Yes" : "No")
                                
                                if !specialInstructions.isEmpty {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Special Instructions")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                        Text(specialInstructions)
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("What happens next?")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Admin will review and contact you to discuss pricing and schedule.")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
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
                                submitRequest()
                            }) {
                                Text("Confirm & Send Request")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("goodPurple"))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle(showSuccess ? "Success" : "Confirm Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showSuccess {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Move Request Saving
    @State private var showConfirmation = false
    @State private var showValidationError = false
    @State private var errorMessage = ""
    private let svc = MoveRequestService()
    
    func submitRequest() {
        showValidationError = false
        errorMessage = ""

        guard let rooms = Int(numberOfRooms),
              let floor = Int(floorLevel) else {
            errorMessage = "Rooms and floor level must be numbers."
            showValidationError = true
            return
        }

        let fragile = Int(numberOfFragileItems) ?? 0

        let addr = Address(
            addressLine: addressLine,
            city: city,
            province: province,
            postalCode: postalCode
        )

        Task {
            do {
                _ = try await svc.createMoveRequest(
                    pickupAddress: addr,
                    numberOfRooms: rooms,
                    numberOfFragileItems: fragile,
                    floorLevel: floor,
                    hasElevator: hasElevator,
                    specialInstructions: specialInstructions
                )

                // ✅ Update UI on success
                withAnimation {
                    showSuccess = true
                }

                // Optional: auto close after 2.5 sec like you already do elsewhere
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    presentationMode.wrappedValue.dismiss()
                }

            } catch {
                errorMessage = error.localizedDescription
                showValidationError = true
            }
        }
    }
}
