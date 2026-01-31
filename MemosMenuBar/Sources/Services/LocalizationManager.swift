import Foundation
import SwiftUI

/// Supported languages in the app
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case spanish = "es"
    case french = "fr"
    case turkish = "tr"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .german:
            return "Deutsch"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        case .turkish:
            return "Türkçe"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

/// Manages app localization and language preferences
@MainActor
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("appLanguage") private var storedLanguage: String = AppLanguage.english.rawValue
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            storedLanguage = currentLanguage.rawValue
            bundle = Self.bundle(for: currentLanguage)
        }
    }
    
    private(set) var bundle: Bundle
    
    private init() {
        let language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "") ?? .english
        self.currentLanguage = language
        self.bundle = Self.bundle(for: language)
    }
    
    /// Gets the bundle for a specific language
    private static func bundle(for language: AppLanguage) -> Bundle {
        // For Swift Packages, use Bundle.module which contains the resources
        guard let path = Bundle.module.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.module
        }
        return bundle
    }
    
    /// Localizes a string key
    func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    /// Localizes a string key with format arguments
    func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: nil, table: nil)
        return String(format: format, arguments: arguments)
    }
}

// MARK: - String Extension for Localization

extension String {
    /// Returns the localized string for this key
    @MainActor
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
    
    /// Returns the localized string with format arguments
    @MainActor
    func localized(_ arguments: CVarArg...) -> String {
        let format = LocalizationManager.shared.localized(self)
        return String(format: format, arguments: arguments)
    }
}
