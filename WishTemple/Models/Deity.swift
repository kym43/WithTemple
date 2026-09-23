import Foundation

struct Deity: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var alias: String?
    var origin: String
    var domain: String
    var howToWorship: String
    var imageName: String
    var sourceName: String? = nil
    var sourceURL: URL? = nil
}
