import Foundation
import SwiftUI

/// Tag insertion mode
enum TagMode: String, CaseIterable, Identifiable {
    case prepend
    case append
    
    var id: String { rawValue }
    
    @MainActor
    var displayName: String {
        switch self {
        case .prepend:
            return "settings.tags.mode.prepend".localized
        case .append:
            return "settings.tags.mode.append".localized
        }
    }
}

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("serverURL") var serverURL: String = ""
    @AppStorage("accessToken") var accessToken: String = ""
    
    // Tag settings
    @AppStorage("tagsEnabled") var tagsEnabled: Bool = false
    @AppStorage("tagMode") private var tagModeRaw: String = TagMode.append.rawValue
    @AppStorage("tags") private var tagsData: Data = Data()
    
    var tagMode: TagMode {
        get { TagMode(rawValue: tagModeRaw) ?? .append }
        set { tagModeRaw = newValue.rawValue }
    }
    
    var tags: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: tagsData)) ?? []
        }
        set {
            tagsData = (try? JSONEncoder().encode(newValue)) ?? Data()
            objectWillChange.send()
        }
    }
    
    private init() {}
    
    var isConfigured: Bool {
        !serverURL.isEmpty && !accessToken.isEmpty
    }
    
    /// Normalizes the server URL by removing trailing slashes
    var normalizedServerURL: String {
        var url = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
        while url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }
    
    /// Returns the full API endpoint URL for creating memos
    func memoEndpointURL() -> URL? {
        let baseURL = normalizedServerURL
        guard !baseURL.isEmpty else { return nil }
        return URL(string: "\(baseURL)/api/v1/memos")
    }
    
    /// Formats tags as a string for memo content
    func formattedTags() -> String {
        guard tagsEnabled, !tags.isEmpty else { return "" }
        return tags.map { "#\($0)" }.joined(separator: " ")
    }
    
    /// Applies tags to content based on mode
    func applyTags(to content: String) -> String {
        let tagString = formattedTags()
        guard !tagString.isEmpty else { return content }
        
        switch tagMode {
        case .prepend:
            return "\(tagString)\n\n\(content)"
        case .append:
            return "\(content)\n\n\(tagString)"
        }
    }
}
