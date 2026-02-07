//
//  AuthManager.swift
//  FireBaseExample
//
//  Created by user285578 on 10/21/25.
//
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var user: User?            // Firebase Auth user
    @Published var appUser: UserModel?    // Firestore user data
    
    private let db = Firestore.firestore()

    init() {
        self.user = Auth.auth().currentUser
        fetchCurrentAppUser() // Load Firestore user if logged in
    }
    
    func signUp(email: String, password: String, displayName: String, completion: @escaping(Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user found"])))
                return
            }

            let newUser = UserModel(email: email, displayName: displayName, isActive: true, id: user.uid)
            do {
                try self.db.collection("users").document(user.uid).setData(from: newUser)
                self.user = user
                self.appUser = newUser
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func login(email: String, password: String, completion: @escaping(Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = result?.user {
                self.user = user
                self.fetchCurrentAppUser()
                completion(.success(user))
            }
        }
    }

    
    func fetchCurrentAppUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot {
                do {
                    let fetchedUser = try snapshot.data(as: UserModel.self)
                    DispatchQueue.main.async {
                        self.appUser = fetchedUser
                    }
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateProfile(displayName: String, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).updateData([
            "displayName": displayName
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // Update locally
            self.appUser?.displayName = displayName
            completion(.success(()))
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.appUser = nil
        } catch {
            print("Error Signing out: \(error.localizedDescription)")
        }
    }
}


