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
    
    var body: some View {
        ZStack {

            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {

                    VStack(spacing: 10) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("goodPurple"))
                            .padding(.top, 20)
                        
                        Text("Move Details")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                
                    }
                    .padding(.bottom, 20)
                    

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
                    

                    VStack(spacing: 20) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Rooms")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Enter number of rooms", text: $numberOfRooms)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Number of Fragile Items")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            TextField("Enter number of fragile items", text: $numberOfFragileItems)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Floor Level")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
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
                                .foregroundColor(.gray)
                            
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
        
        return true
    }
}


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
                            VStack(spacing: 20) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color("goodPurple"))
                                    .padding(.top, 40)
                                
                                Text("Review Your Request")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("Make sure everything is correct")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
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
    
    func submitRequest() {
        // to improve later
        withAnimation {
            showSuccess = true
        }
        
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            presentationMode.wrappedValue.dismiss()
        }
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

#Preview {
    NavigationView {
        OrganizeMoveView()
    }
}
