import Foundation

enum LocalRecordServiceError: Error, Equatable {
    case duplicateIdentifier
    case duplicateRecord
    case recordNotFound
}

func appendLocalRecord<Record: Identifiable>(
    _ record: Record,
    to records: inout [Record],
    isDuplicate: (Record) -> Bool = { _ in false }
) throws where Record.ID: Equatable {
    guard !records.contains(where: { $0.id == record.id }) else {
        throw LocalRecordServiceError.duplicateIdentifier
    }

    guard !records.contains(where: isDuplicate) else {
        throw LocalRecordServiceError.duplicateRecord
    }

    records.append(record)
}

func deleteLocalRecord<Record: Identifiable>(
    id: Record.ID,
    from records: inout [Record]
) throws where Record.ID: Equatable {
    guard let index = records.firstIndex(where: { $0.id == id }) else {
        throw LocalRecordServiceError.recordNotFound
    }

    records.remove(at: index)
}
