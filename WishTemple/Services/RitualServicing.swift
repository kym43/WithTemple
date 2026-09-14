import Foundation

private protocol RecipientRitualRecord: Identifiable {
    var recipientNickname: String { get }
    var ritualCycleID: AnnualRitualCycle.ID { get }
}

extension TaisuiRecord: RecipientRitualRecord {}
extension LightLampRecord: RecipientRitualRecord {}

protocol RitualServicing: Sendable {
    func fetchAnnualRitualCycles() async throws -> [AnnualRitualCycle]

    func fetchTaisuiRecords() async throws -> [TaisuiRecord]
    func createTaisuiRecord(_ record: TaisuiRecord) async throws
    func deleteTaisuiRecord(id: TaisuiRecord.ID) async throws

    func fetchLightLampRecords() async throws -> [LightLampRecord]
    func createLightLampRecord(_ record: LightLampRecord) async throws
    func deleteLightLampRecord(id: LightLampRecord.ID) async throws
}

actor MockRitualService: RitualServicing {
    private var cycles: [AnnualRitualCycle]
    private var taisuiRecords: [TaisuiRecord]
    private var lightLampRecords: [LightLampRecord]

    init(
        cycles: [AnnualRitualCycle] = MockRitualService.defaultCycles,
        taisuiRecords: [TaisuiRecord] = [],
        lightLampRecords: [LightLampRecord] = []
    ) {
        self.cycles = cycles
        self.taisuiRecords = taisuiRecords
        self.lightLampRecords = lightLampRecords
    }

    func fetchAnnualRitualCycles() async throws -> [AnnualRitualCycle] {
        cycles.sorted { $0.startsAt > $1.startsAt }
    }

    func fetchTaisuiRecords() async throws -> [TaisuiRecord] {
        taisuiRecords.sorted { $0.createdAt > $1.createdAt }
    }

    func createTaisuiRecord(_ record: TaisuiRecord) async throws {
        try Self.createRitualRecord(record, in: &taisuiRecords)
    }

    func deleteTaisuiRecord(id: TaisuiRecord.ID) async throws {
        try deleteLocalRecord(id: id, from: &taisuiRecords)
    }

    func fetchLightLampRecords() async throws -> [LightLampRecord] {
        lightLampRecords.sorted { $0.createdAt > $1.createdAt }
    }

    func createLightLampRecord(_ record: LightLampRecord) async throws {
        try Self.createRitualRecord(record, in: &lightLampRecords)
    }

    func deleteLightLampRecord(id: LightLampRecord.ID) async throws {
        try deleteLocalRecord(id: id, from: &lightLampRecords)
    }

    private static func createRitualRecord<Record: RecipientRitualRecord>(
        _ record: Record,
        in records: inout [Record]
    ) throws where Record.ID: Equatable {
        try appendLocalRecord(record, to: &records) { existingRecord in
            existingRecord.ritualCycleID == record.ritualCycleID
                && normalizedRecipient(existingRecord.recipientNickname)
                    == normalizedRecipient(record.recipientNickname)
        }
    }

    private static func normalizedRecipient(_ nickname: String) -> String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static let defaultCycles: [AnnualRitualCycle] = [
        AnnualRitualCycle(
            id: "mock-2027",
            displayName: "2027 測試年度",
            startsAt: Date(timeIntervalSince1970: 1_798_761_600),
            endsAt: Date(timeIntervalSince1970: 1_830_297_599),
            isOpen: true
        )
    ]
}
