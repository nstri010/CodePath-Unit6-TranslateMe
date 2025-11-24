//
//  TranslationAPI.swift
//  TranslateMe
//
//  Created by Nakisha S. on 11/23/25.


import Foundation

class TranslationAPI {

    /// - Parameters:
    ///   - text: The English text to translate.
    ///   - target: Target language code, e.g. "es", "fr", "ko".
    func translate(text: String, to target: String) async throws -> String {

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed

        let urlString = "https://api.mymemory.translated.net/get?q=\(encoded)&langpair=en|\(target)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let responseData = json["responseData"] as? [String: Any],
           let translatedText = responseData["translatedText"] as? String {
            return translatedText
        }

        return "Translation failed."
    }
}
