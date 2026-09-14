import Foundation

struct Temple: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var summary: String
    var history: String
    var highlights: [String]
    var imageName: String
}

struct ArchitectureFeature: Identifiable, Hashable, Codable {
    enum Category: String, Codable {
        case pillar, roof, carving, courtyard, other
    }

    let id: UUID
    var name: String
    var category: Category
    var explanation: String
    var imageName: String
}
