import Foundation
import SwiftData

@ModelActor
actor SwiftDataWishService: WishServicing {
    func fetchWishes() throws -> [WishEntry] {
        try fetchStoredWishes().map(\.wishEntry)
    }

    func createWish(_ wish: WishEntry) throws {
        guard try fetchStoredWish(id: wish.id) == nil else {
            throw LocalRecordServiceError.duplicateIdentifier
        }

        modelContext.insert(StoredWish(wish: wish))
        try saveChanges()
    }

    func deleteWish(id: WishEntry.ID) throws {
        guard let storedWish = try fetchStoredWish(id: id) else {
            throw LocalRecordServiceError.recordNotFound
        }

        modelContext.delete(storedWish)
        try saveChanges()
    }

    func deleteAllWishes() throws {
        let descriptor = FetchDescriptor<StoredWish>()
        for storedWish in try modelContext.fetch(descriptor) {
            modelContext.delete(storedWish)
        }

        try saveChanges()
    }

    func exportWishes() throws -> Data {
        try WishExportArchive.encode(wishes: fetchWishes())
    }

    private func fetchStoredWishes() throws -> [StoredWish] {
        let descriptor = FetchDescriptor<StoredWish>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func fetchStoredWish(id: UUID) throws -> StoredWish? {
        var descriptor = FetchDescriptor<StoredWish>(
            predicate: #Predicate { storedWish in
                storedWish.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func saveChanges() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
