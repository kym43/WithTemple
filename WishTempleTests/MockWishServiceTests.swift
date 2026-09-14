import XCTest
@testable import WishTemple

@MainActor
final class MockWishServiceTests: XCTestCase {
    func testCreateFetchAndDeleteWish() async throws {
        let service = MockWishService()
        let wish = WishEntry(
            id: UUID(),
            deityID: UUID(),
            content: "願家人平安",
            createdAt: Date()
        )

        try await service.createWish(wish)
        let createdWishes = try await service.fetchWishes()
        XCTAssertEqual(createdWishes, [wish])

        try await service.deleteWish(id: wish.id)
        let remainingWishes = try await service.fetchWishes()
        XCTAssertTrue(remainingWishes.isEmpty)
    }

    func testDuplicateWishIdentifierIsRejected() async throws {
        let wish = WishEntry(
            id: UUID(),
            deityID: UUID(),
            content: "願事事順心",
            createdAt: Date()
        )
        let service = MockWishService(initialWishes: [wish])

        do {
            try await service.createWish(wish)
            XCTFail("Expected a duplicate identifier error")
        } catch {
            XCTAssertEqual(error as? LocalRecordServiceError, .duplicateIdentifier)
        }
    }
}
