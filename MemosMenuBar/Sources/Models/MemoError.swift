import Foundation

enum MemoError: LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(statusCode: Int)
    case networkError(underlying: Error)
    case encodingError
    case missingConfiguration
    
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error.invalid.url", bundle: .module, comment: "")
        case .unauthorized:
            return NSLocalizedString("error.unauthorized", bundle: .module, comment: "")
        case .serverError(let statusCode):
            return String(format: NSLocalizedString("error.server", bundle: .module, comment: ""), statusCode)
        case .networkError(let underlying):
            return String(format: NSLocalizedString("error.network", bundle: .module, comment: ""), underlying.localizedDescription)
        case .encodingError:
            return NSLocalizedString("error.encoding", bundle: .module, comment: "")
        case .missingConfiguration:
            return NSLocalizedString("error.missing.config", bundle: .module, comment: "")
        }
    }
}
