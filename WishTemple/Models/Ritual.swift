import Foundation

struct AnnualRitualCycle: Identifiable, Hashable, Codable, Sendable {
    let id: String
    var displayName: String
    var startsAt: Date
    var endsAt: Date
    var isOpen: Bool

    func isAvailable(at date: Date) -> Bool {
        guard isOpen, startsAt <= endsAt else {
            return false
        }

        return date >= startsAt && date <= endsAt
    }
}

enum RitualRecordStatus: String, Codable, Sendable {
    case completed
}

enum Zodiac: String, CaseIterable, Codable, Sendable {
    case rat
    case ox
    case tiger
    case rabbit
    case dragon
    case snake
    case horse
    case goat
    case monkey
    case rooster
    case dog
    case pig
}

enum LightLampStyle: String, CaseIterable, Codable, Sendable {
    case traditional
    case lotus
    case minimal
}

struct TaisuiRecord: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var zodiac: Zodiac
    var recipientNickname: String
    var ritualCycleID: AnnualRitualCycle.ID
    var createdAt: Date
    var status: RitualRecordStatus
}

struct LightLampRecord: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var lampStyle: LightLampStyle
    var recipientNickname: String
    var ritualCycleID: AnnualRitualCycle.ID
    var createdAt: Date
    var status: RitualRecordStatus
}
