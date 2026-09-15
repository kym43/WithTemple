import Foundation
import SwiftData

enum WishPersistence {
    static let schema = Schema(versionedSchema: WishTempleSchemaV1.self)

    static func makeModelContainer(
        isStoredInMemoryOnly: Bool = false
    ) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            "WishTemple",
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly,
            groupContainer: .none,
            cloudKitDatabase: .none
        )

        return try makeModelContainer(configuration: configuration)
    }

    static func makeModelContainer(storeURL: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            "WishTemple",
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )

        return try makeModelContainer(configuration: configuration)
    }

    private static func makeModelContainer(
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        return try ModelContainer(
            for: schema,
            migrationPlan: WishTempleMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
