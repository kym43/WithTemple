import Foundation
import SwiftData

enum WishTempleSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static let models: [any PersistentModel.Type] = [StoredWish.self]

    @Model
    final class StoredWish {
        @Attribute(.unique) var id: UUID
        var deityID: UUID
        var content: String
        var createdAt: Date

        init(id: UUID, deityID: UUID, content: String, createdAt: Date) {
            self.id = id
            self.deityID = deityID
            self.content = content
            self.createdAt = createdAt
        }

        convenience init(wish: WishEntry) {
            self.init(
                id: wish.id,
                deityID: wish.deityID,
                content: wish.content,
                createdAt: wish.createdAt
            )
        }

        var wishEntry: WishEntry {
            WishEntry(
                id: id,
                deityID: deityID,
                content: content,
                createdAt: createdAt
            )
        }
    }
}

enum WishTempleMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [WishTempleSchemaV1.self]
    static let stages: [MigrationStage] = []
}

typealias StoredWish = WishTempleSchemaV1.StoredWish
