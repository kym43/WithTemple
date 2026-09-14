import Foundation

struct WishEntry: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var deityID: Deity.ID
    var content: String
    var createdAt: Date
}
