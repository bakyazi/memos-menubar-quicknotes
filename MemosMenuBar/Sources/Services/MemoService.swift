import Foundation

actor MemoService {
    static let shared = MemoService()
    
    private init() {}
    
    func createMemo(content: String) async throws {
        // Get settings from main actor
        let (endpointURL, token) = await MainActor.run {
            let settings = SettingsManager.shared
            return (settings.memoEndpointURL(), settings.accessToken)
        }
        
        guard let url = endpointURL else {
            throw MemoError.invalidURL
        }
        
        guard !token.isEmpty else {
            throw MemoError.missingConfiguration
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode body
        let memoRequest = MemoRequest(content: content)
        do {
            request.httpBody = try JSONEncoder().encode(memoRequest)
        } catch {
            throw MemoError.encodingError
        }
        
        // Perform request
        let (_, response): (Data, URLResponse)
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw MemoError.networkError(underlying: error)
        }
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MemoError.networkError(underlying: NSError(domain: "MemoService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401, 403:
            throw MemoError.unauthorized
        default:
            throw MemoError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
