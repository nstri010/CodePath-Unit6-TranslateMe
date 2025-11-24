//
//  LoginView.swift
//  TranslateMe
//
//  Created by Nakisha S. on 11/23/25.
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authManager: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {

            Text("TranslateMe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Welcome! Please sign in or create an account to continue.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button {
                Task { await handleSignIn() }
            } label: {
                Text(isSigningIn ? "Signing In..." : "Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isSigningIn)

            Button {
                Task { await handleSignUp() }
            } label: {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - LOGIN
    func handleSignIn() async {
        isSigningIn = true
        errorMessage = ""

        do {
            try await authManager.signIn(email: email, password: password)
        } catch {
            errorMessage = "Login failed. Check your email and password."
        }

        isSigningIn = false
    }

    // MARK: - SIGN UP
    func handleSignUp() async {
        isSigningIn = true
        errorMessage = ""

        do {
            try await authManager.signUp(email: email, password: password)
        } catch {
            errorMessage = "Account creation failed."
        }

        isSigningIn = false
    }
}
