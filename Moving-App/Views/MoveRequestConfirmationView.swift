//
//  MoveRequestConfirmationView.swift
//  Moving-App
//
//  Created by user285578 on 2/25/26.
//

import SwiftUI

struct MoveRequestConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode

    let pickupAddress: Address
    let destinationAddress: Address
    let numberOfRooms: String
    let numberOfFragileItems: String
    let floorLevel: String
    let hasElevator: Bool
    let specialInstructions:  String

    @State private var showSuccess = false
    @State private var showValidationError = false
    @State private var errorMessage = ""

    private let svc = MoveRequestService()

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

                                Text("Request Sent")
                                    .font(.system(size: 28, weight: .bold))

                                Text("The admin will review your move request and contact you soon")
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

                                Text("After submitting, details cannot be changed.")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }

                            VStack(alignment: .leading, spacing: 15) {

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Pickup Address")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Text(pickupAddress.addressLine)
                                    Text("\(pickupAddress.city), \(pickupAddress.province) \(pickupAddress.postalCode)")
                                        .foregroundColor(.gray)
                                }

                                Divider()

                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Destination Address")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                    Text(destinationAddress.addressLine)
                                    Text("\(destinationAddress.city), \(destinationAddress.province) \(destinationAddress.postalCode)")
                                        .foregroundColor(.gray)
                                }

                                Divider()

                                DetailRow(label: "Number of Rooms", value: numberOfRooms)
                                Divider()
                                DetailRow(label: "Fragile Items", value: numberOfFragileItems.isEmpty ? "None" : numberOfFragileItems)
                                Divider()
                                DetailRow(label: "Floor Level", value: floorLevel)
                                Divider()
                                DetailRow(label: "Elevator", value: hasElevator ? "Yes" : "No")

                                if !specialInstructions.isEmpty {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Special Instructions")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                        Text(specialInstructions)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
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

                            Button(action: submitRequest) {
                                Text("Confirm and Send Request")
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
                        Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                    }
                }
            }
        }
    }

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

        Task {
            do {
                _ = try await svc.createMoveRequest(
                    pickupAddress: pickupAddress,
                    destinationAddress: destinationAddress,
                    numberOfRooms: rooms,
                    numberOfFragileItems: fragile,
                    floorLevel: floor,
                    hasElevator: hasElevator,
                    specialInstructions: specialInstructions
                )

                withAnimation { showSuccess = true }

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
