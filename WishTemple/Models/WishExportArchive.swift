import Foundation

/// A versioned, portable representation of locally stored wishes.
struct WishExportArchive: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 1

    private static let fractionalDateFormatOptions: ISO8601DateFormatter.Options = [
        .withInternetDateTime,
        .withFractionalSeconds,
    ]
    private static let wholeSecondDateFormatOptions: ISO8601DateFormatter.Options = [
        .withInternetDateTime,
    ]

    let schemaVersion: Int
    let exportedAt: Date
    let wishes: [WishEntry]

    init(
        schemaVersion: Int = currentSchemaVersion,
        exportedAt: Date = Date(),
        wishes: [WishEntry]
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.wishes = wishes
    }

    static func encode(
        wishes: [WishEntry],
        exportedAt: Date = Date()
    ) throws -> Data {
        let archive = WishExportArchive(exportedAt: exportedAt, wishes: wishes)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            try Self.encodeDate(date, to: encoder)
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(archive)
    }

    static func decode(from data: Data) throws -> WishExportArchive {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            try Self.decodeDate(from: decoder)
        }
        return try decoder.decode(WishExportArchive.self, from: data)
    }

    private static func encodeDate(_ date: Date, to encoder: Encoder) throws {
        // ISO8601DateFormatter emits only milliseconds, so compose the UTC value
        // from Date's reference interval to retain the submillisecond component.
        let timeInterval = date.timeIntervalSinceReferenceDate
        var wholeSeconds = floor(timeInterval)
        var nanoseconds = Int64(
            ((timeInterval - wholeSeconds) * 1_000_000_000).rounded()
        )

        if nanoseconds == 1_000_000_000 {
            wholeSeconds += 1
            nanoseconds = 0
        }

        let wholeSecondString = ISO8601DateFormatter.string(
            from: Date(timeIntervalSinceReferenceDate: wholeSeconds),
            timeZone: TimeZone(secondsFromGMT: 0)!,
            formatOptions: wholeSecondDateFormatOptions
        )
        var fractionalSeconds = String(
            format: "%09lld",
            locale: Locale(identifier: "en_US_POSIX"),
            nanoseconds
        )
        while fractionalSeconds.count > 3, fractionalSeconds.last == "0" {
            fractionalSeconds.removeLast()
        }
        let dateString = String(wholeSecondString.dropLast()) + ".\(fractionalSeconds)Z"

        var container = encoder.singleValueContainer()
        try container.encode(dateString)
    }

    private static func decodeDate(from decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        if let date = decodeUTCDateWithFractionalSeconds(dateString) {
            return date
        }
        if let date = makeDateFormatter(options: fractionalDateFormatOptions).date(from: dateString) {
            return date
        }
        if let date = makeDateFormatter(options: wholeSecondDateFormatOptions).date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid ISO 8601 date: \(dateString)"
        )
    }

    private static func decodeUTCDateWithFractionalSeconds(_ dateString: String) -> Date? {
        // ISO8601DateFormatter also truncates fractional seconds while parsing.
        guard dateString.hasSuffix("Z"),
              let separatorIndex = dateString.lastIndex(of: ".") else {
            return nil
        }

        let fractionStartIndex = dateString.index(after: separatorIndex)
        let fractionEndIndex = dateString.index(before: dateString.endIndex)
        let fractionalSeconds = dateString[fractionStartIndex..<fractionEndIndex]
        guard !fractionalSeconds.isEmpty,
              fractionalSeconds.allSatisfy(\.isNumber),
              let fraction = Double("0.\(fractionalSeconds)") else {
            return nil
        }

        let wholeSecondString = String(dateString[..<separatorIndex]) + "Z"
        guard let wholeSecondDate = makeDateFormatter(
            options: wholeSecondDateFormatOptions
        ).date(from: wholeSecondString) else {
            return nil
        }

        return Date(
            timeIntervalSinceReferenceDate:
                wholeSecondDate.timeIntervalSinceReferenceDate + fraction
        )
    }

    private static func makeDateFormatter(
        options: ISO8601DateFormatter.Options
    ) -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = options
        return formatter
    }
}
