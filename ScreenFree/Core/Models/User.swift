import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let createdAt: Date

    init(id: UUID = UUID(), email: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }
}
