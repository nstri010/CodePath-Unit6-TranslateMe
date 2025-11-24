//
//  TranslatorHomeView.swift
//  TranslateMe
//
//  Created by Nakisha S. on 11/23/25.


import SwiftUI

struct TranslationRecord: Identifiable {
    let id = UUID()
    let original: String
    let translated: String
    let targetLanguageName: String
    let date: Date
}

/// Supported languages
enum TargetLanguage: String, CaseIterable, Identifiable {
    case spanish = "es"
    case french  = "fr"
    case korean  = "ko"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .spanish: return "Spanish"
        case .french:  return "French"
        case .korean:  return "Korean"
        }
    }
}

struct TranslatorHomeView: View {

    @EnvironmentObject var authManager: AuthManager

    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isTranslating: Bool = false

    @State private var targetLanguage: TargetLanguage = .spanish
    @State private var history: [TranslationRecord] = []

    private let api = TranslationAPI()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("TranslateMe")
                    .font(.largeTitle.bold())
                    .padding(.top, 8)

                Text("Enter text in English, choose a language, and tap Translate.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text to Translate")
                        .font(.headline)

                    TextEditor(text: $inputText)
                        .frame(minHeight: 80, maxHeight: 140)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                // Language Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Translate To")
                        .font(.headline)

                    Picker("Translate To", selection: $targetLanguage) {
                        ForEach(TargetLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                // Translate button
                Button {
                    Task { await performTranslation() }
                } label: {
                    if isTranslating {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Translate")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isTranslating || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                // Output
                VStack(alignment: .leading, spacing: 8) {
                    Text("Translation")
                        .font(.headline)

                    ZStack(alignment: .topLeading) {
                        if outputText.isEmpty {
                            Text("Your translation will appear here.")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }

                        ScrollView {
                            Text(outputText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                        }
                    }
                    .frame(minHeight: 80, maxHeight: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                // History header + Clear button
                HStack {
                    Text("History")
                        .font(.headline)

                    Spacer()

                    Button("Clear History") {
                        history.removeAll()
                    }
                    .foregroundColor(.red)
                }
                .padding(.horizontal)

                // History list
                if history.isEmpty {
                    Text("No translations yet.")
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(history) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("EN: \(item.original)")
                                        .font(.subheadline)

                                    Text("\(item.targetLanguageName): \(item.translated)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)

                                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }

                Spacer(minLength: 10)
            }
            .navigationTitle("Translator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        authManager.signOut()
                    }
                }
            }
        }
    }

    // MARK: - Translation Logic

    private func performTranslation() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isTranslating = true
        defer { isTranslating = false }

        do {
            let translated = try await api.translate(
                text: text,
                to: targetLanguage.rawValue
            )

            outputText = translated

            let record = TranslationRecord(
                original: text,
                translated: translated,
                targetLanguageName: targetLanguage.displayName,
                date: Date()
            )
            history.insert(record, at: 0)

        } catch {
            outputText = "Error: \(error.localizedDescription)"
        }
    }
}
