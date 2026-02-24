import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class AuthManager: ObservableObject {

    @Published var user: UserModel?
    @Published var isLoading = false
    @Published var authError: String?

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
}
