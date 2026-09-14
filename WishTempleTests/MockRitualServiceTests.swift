import XCTest
@testable import WishTemple

@MainActor
final class MockRitualServiceTests: XCTestCase {
    func testCycleWithReversedDatesIsUnavailable() {
        let cycle = AnnualRitualCycle(
            id: "reversed-cycle",
            displayName: "Reversed cycle",
            startsAt: Date(timeIntervalSince1970: 200),
            endsAt: Date(timeIntervalSince1970: 100),
            isOpen: true
        )

        XCTAssertFalse(cycle.isAvailable(at: Date(timeIntervalSince1970: 150)))
    }

    func testDuplicateTaisuiRecordForSameCycleAndRecipientIsRejected() async throws {
        let existingRecord = TaisuiRecord(
            id: UUID(),
            zodiac: .dragon,
            recipientNickname: "小明",
            ritualCycleID: "2027",
            createdAt: Date(),
            status: .completed
        )
        let duplicateRecord = TaisuiRecord(
            id: UUID(),
            zodiac: .dragon,
            recipientNickname: " 小明 ",
            ritualCycleID: "2027",
            createdAt: Date(),
            status: .completed
        )
        let service = MockRitualService(taisuiRecords: [existingRecord])

        do {
            try await service.createTaisuiRecord(duplicateRecord)
            XCTFail("Expected a duplicate record error")
        } catch {
            XCTAssertEqual(error as? LocalRecordServiceError, .duplicateRecord)
        }
    }

    func testLightLampRecordsAreReturnedNewestFirst() async throws {
        let olderRecord = makeLightLampRecord(createdAt: Date(timeIntervalSince1970: 100))
        let newerRecord = makeLightLampRecord(createdAt: Date(timeIntervalSince1970: 200))
        let service = MockRitualService(lightLampRecords: [olderRecord, newerRecord])

        let records = try await service.fetchLightLampRecords()

        XCTAssertEqual(records.map(\.id), [newerRecord.id, olderRecord.id])
    }

    func testRecipientComparisonUsesLocaleIndependentCaseNormalization() async throws {
        let existingRecord = TaisuiRecord(
            id: UUID(),
            zodiac: .dragon,
            recipientNickname: "I",
            ritualCycleID: "2027",
            createdAt: Date(),
            status: .completed
        )
        let duplicateRecord = TaisuiRecord(
            id: UUID(),
            zodiac: .dragon,
            recipientNickname: "i",
            ritualCycleID: "2027",
            createdAt: Date(),
            status: .completed
        )
        let service = MockRitualService(taisuiRecords: [existingRecord])

        do {
            try await service.createTaisuiRecord(duplicateRecord)
            XCTFail("Expected a duplicate record error")
        } catch {
            XCTAssertEqual(error as? LocalRecordServiceError, .duplicateRecord)
        }
    }

    private func makeLightLampRecord(createdAt: Date) -> LightLampRecord {
        LightLampRecord(
            id: UUID(),
            lampStyle: .lotus,
            recipientNickname: "家人",
            ritualCycleID: "2027",
            createdAt: createdAt,
            status: .completed
        )
    }
}
