//
//  TranslateMeApp.swift
//  TranslateMe
//
//  Created by Nakisha S. on 11/23/25.
//

import SwiftUI
import FirebaseCore

@main
struct TranslateMeApp: App {

    @StateObject private var authManager = AuthManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.user != nil {
                ContentView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
