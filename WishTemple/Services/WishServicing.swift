import Foundation

protocol WishServicing: Sendable {
    func fetchWishes() async throws -> [WishEntry]
    func createWish(_ wish: WishEntry) async throws
    func deleteWish(id: WishEntry.ID) async throws
    func deleteAllWishes() async throws
}

actor MockWishService: WishServicing {
    private var wishes: [WishEntry]

    init(initialWishes: [WishEntry] = []) {
        wishes = initialWishes
    }

    func fetchWishes() async throws -> [WishEntry] {
        wishes.sorted { $0.createdAt > $1.createdAt }
    }

    func createWish(_ wish: WishEntry) async throws {
        try appendLocalRecord(wish, to: &wishes)
    }

    func deleteWish(id: WishEntry.ID) async throws {
        try deleteLocalRecord(id: id, from: &wishes)
    }

    func deleteAllWishes() async throws {
        wishes.removeAll()
    }
}
