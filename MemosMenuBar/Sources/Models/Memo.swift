import Foundation

struct MemoRequest: Codable {
    let content: String
}

struct MemoResponse: Codable {
    let id: Int?
    let content: String?
}
