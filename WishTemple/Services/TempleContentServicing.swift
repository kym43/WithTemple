import Foundation

protocol TempleContentServicing {
    func fetchTemple() async throws -> Temple
    func fetchDeities() async throws -> [Deity]
    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature]
}

struct MockTempleContentService: TempleContentServicing {
    func fetchTemple() async throws -> Temple {
        Temple(
            id: UUID(),
            name: "心願廟",
            summary: "一座從簡樸小廟開始，隨大家心意慢慢擴建的線上廟宇。",
            history: "",
            highlights: [],
            imageName: "temple_placeholder"
        )
    }

    func fetchDeities() async throws -> [Deity] {
        []
    }

    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature] {
        []
    }
}
