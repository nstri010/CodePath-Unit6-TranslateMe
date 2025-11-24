//
//  AuthManager.swift
//  TranslateMe
//
//  Created by Nakisha S. on 11/23/25.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthManager: ObservableObject {

    @Published var user: User?
    let isMocked: Bool

    private var handle: AuthStateDidChangeListenerHandle?

    var userEmail: String? {
        isMocked ? "mock@demo.com" : user?.email
    }

    init(isMocked: Bool = false) {
        self.isMocked = isMocked

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.user = result.user
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print("Sign out error:", error)
        }
    }
}
