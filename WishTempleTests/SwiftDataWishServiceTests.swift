import Foundation
import SwiftData
import XCTest
@testable import WishTemple

@MainActor
final class SwiftDataWishServiceTests: XCTestCase {
    func testCRUDAndNewestFirstOrdering() async throws {
        let service = try makeService()
        let olderWish = makeWish(content: "第一個願望", createdAt: Date(timeIntervalSince1970: 100))
        let newerWish = makeWish(content: "第二個願望", createdAt: Date(timeIntervalSince1970: 200))

        try await service.createWish(olderWish)
        try await service.createWish(newerWish)
        let createdWishes = try await service.fetchWishes()
        XCTAssertEqual(createdWishes, [newerWish, olderWish])

        try await service.deleteWish(id: newerWish.id)
        let remainingWishes = try await service.fetchWishes()
        XCTAssertEqual(remainingWishes, [olderWish])

        try await service.deleteAllWishes()
        let wishesAfterDeletingAll = try await service.fetchWishes()
        XCTAssertTrue(wishesAfterDeletingAll.isEmpty)
    }

    func testDuplicateIdentifierAndMissingDeleteUseServiceErrors() async throws {
        let service = try makeService()
        let wish = makeWish()
        try await service.createWish(wish)

        do {
            try await service.createWish(wish)
            XCTFail("Expected a duplicate identifier error")
        } catch {
            XCTAssertEqual(error as? LocalRecordServiceError, .duplicateIdentifier)
        }

        do {
            try await service.deleteWish(id: UUID())
            XCTFail("Expected a record not found error")
        } catch {
            XCTAssertEqual(error as? LocalRecordServiceError, .recordNotFound)
        }
    }

    func testWishPersistsWhenContainerIsReopened() async throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let storeURL = directoryURL.appendingPathComponent("WishTemple.store")
        let wish = makeWish()

        try await write(wish, to: storeURL)

        let reopenedContainer = try WishPersistence.makeModelContainer(storeURL: storeURL)
        let reopenedService = SwiftDataWishService(modelContainer: reopenedContainer)
        let persistedWishes = try await reopenedService.fetchWishes()
        XCTAssertEqual(persistedWishes, [wish])
    }

    func testExportUsesVersionedPortableArchive() async throws {
        let service = try makeService()
        let wish = makeWish(createdAt: Date(timeIntervalSince1970: 100))
        try await service.createWish(wish)

        let data = try await service.exportWishes()
        let archive = try WishExportArchive.decode(from: data)

        XCTAssertEqual(archive.schemaVersion, WishExportArchive.currentSchemaVersion)
        XCTAssertEqual(archive.wishes, [wish])
    }

    func testExportPreservesSubmillisecondPrecision() throws {
        let createdAt = Date(timeIntervalSince1970: 1_789_380_000.750_123_5)
        let exportedAt = Date(timeIntervalSince1970: 1_789_380_001.125_678_5)
        let wish = makeWish(createdAt: createdAt)

        let data = try WishExportArchive.encode(wishes: [wish], exportedAt: exportedAt)
        let archive = try WishExportArchive.decode(from: data)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let wishes = try XCTUnwrap(json["wishes"] as? [[String: Any]])

        XCTAssertEqual(archive.exportedAt, exportedAt)
        XCTAssertEqual(archive.wishes.first?.createdAt, createdAt)
        XCTAssertEqual(json["exportedAt"] as? String, "2026-09-14T10:00:01.125678539Z")
        XCTAssertEqual(wishes.first?["createdAt"] as? String, "2026-09-14T10:00:00.750123501Z")
    }

    func testDecodeAcceptsLegacyWholeSecondDates() throws {
        let archive = WishExportArchive(
            exportedAt: Date(timeIntervalSince1970: 101),
            wishes: [makeWish(createdAt: Date(timeIntervalSince1970: 100))]
        )
        let legacyEncoder = JSONEncoder()
        legacyEncoder.dateEncodingStrategy = .iso8601

        let data = try legacyEncoder.encode(archive)

        XCTAssertEqual(try WishExportArchive.decode(from: data), archive)
    }

    private func makeService() throws -> SwiftDataWishService {
        let container = try WishPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        return SwiftDataWishService(modelContainer: container)
    }

    private func write(_ wish: WishEntry, to storeURL: URL) async throws {
        let container = try WishPersistence.makeModelContainer(storeURL: storeURL)
        let service = SwiftDataWishService(modelContainer: container)
        try await service.createWish(wish)
    }

    private func makeWish(
        content: String = "願家人平安",
        createdAt: Date = Date(timeIntervalSince1970: 100)
    ) -> WishEntry {
        WishEntry(
            id: UUID(),
            deityID: UUID(),
            content: content,
            createdAt: createdAt
        )
    }
}
