import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthManager: ObservableObject {

    @Published var user: UserModel?
    @Published var isLoading = false
    @Published var authError: String?
    @Published var myMoveRequests: [MoveRequest] = []
    @Published var moveRequestsError: String?

    private let db = Firestore.firestore()

    func bootstrap() async {
        guard let current = Auth.auth().currentUser else {
            user = nil
            return
        }
        await loadUserProfile(uid: current.uid, emailFallback: current.email)
    }

    func signUp(email: String, password: String, displayName: String, role: UserRole) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid

            let profile = UserModel(
                email: email,
                displayName: displayName,
                isActive: true,
                id: uid,
                role: role
            )

            try db.collection("users").document(uid).setData(from: profile, merge: true)
            user = profile
        } catch {
            authError = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let uid = result.user.uid
            await loadUserProfile(uid: uid, emailFallback: email)
        } catch {
            authError = error.localizedDescription
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            authError = error.localizedDescription
        }
    }

    private func loadUserProfile(uid: String, emailFallback: String?) async {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()

            if let existing = try? doc.data(as: UserModel.self) {
                user = existing
                return
            }

            let fallback = UserModel(
                email: emailFallback ?? "",
                displayName: "",
                isActive: true,
                id: uid,
                role: .regular
            )

            try db.collection("users").document(uid).setData(from: fallback, merge: true)
            user = fallback

        } catch {
            authError = error.localizedDescription
            user = nil
        }
    }
    
    //MARK: Address
    
    func saveAddress(_ address: Address) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            authError = "No logged in user."
            return
        }

        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            // Update just the address field (won't overwrite the whole doc)
            try await db.collection("users").document(uid).setData([
                "address": [
                    "addressLine": address.addressLine,
                    "city": address.city,
                    "province": address.province,
                    "postalCode": address.postalCode
                ]
            ], merge: true)

            // Update local @Published user too
            if var current = user {
                current.address = address
                user = current
            }
        } catch {
            authError = error.localizedDescription
        }
    }

    func loadAddress() async -> Address? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            let model = try doc.data(as: UserModel.self)
            user = model
            return model.address
        } catch {
            // Don’t force-error on first-time users with no address
            return nil
        }
    }
    
    func fetchMoveRequests() async {
        moveRequestsError = nil
        guard let uid = Auth.auth().currentUser?.uid else {
            myMoveRequests = []
            moveRequestsError = "No logged in user."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let snap = try await db.collection("moveRequests")
                .whereField("userId", isEqualTo: uid)
                .getDocuments()

            myMoveRequests = try snap.documents.map { try $0.data(as: MoveRequest.self) }

        } catch {
            moveRequestsError = error.localizedDescription
            myMoveRequests = []
        }
    }
}
