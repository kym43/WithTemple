import XCTest
import UIKit
@testable import WishTemple

@MainActor
final class DeityEncyclopediaTests: XCTestCase {
    func testMockServiceReturnsCompleteDeityCatalog() async throws {
        let deities = try await MockTempleContentService().fetchDeities()

        XCTAssertEqual(deities.count, 8)
        XCTAssertEqual(
            Set(deities.map(\.id)),
            Set([
                UUID(uuidString: "0E9750A8-C7D0-48B3-9495-29EAE72B6D6B")!,
                UUID(uuidString: "AF73B4E7-893B-4DB5-8D23-D7F5D59B15D8")!,
                UUID(uuidString: "E302886F-BF17-46C9-9C1A-EFA58D0F2D8F")!,
                UUID(uuidString: "93D4E9ED-9E59-40DA-B346-1E6FFDDC167D")!,
                UUID(uuidString: "0EEE42FA-DB12-4B3B-9635-B728AB5F1B80")!,
                UUID(uuidString: "1D46899A-FA68-402C-898D-F8F5B6E69030")!,
                UUID(uuidString: "1D5953B7-8DD6-4EBD-8285-1A6724C6D7BD")!,
                UUID(uuidString: "F216C5D9-8795-49AA-BAF7-68007013569D")!
            ])
        )
        XCTAssertTrue(deities.allSatisfy { !$0.name.isEmpty && !$0.domain.isEmpty })
        XCTAssertTrue(deities.allSatisfy { $0.sourceName != nil && $0.sourceURL != nil })
        XCTAssertEqual(Set(deities.map(\.imageName)).count, deities.count)
        for deity in deities {
            XCTAssertNotNil(UIImage(named: deity.imageName), "Missing image asset: \(deity.imageName)")
        }
    }

    func testLoadTransitionsFromLoadingToLoaded() async {
        let service = SuspendingTempleContentService()
        let viewModel = DeityEncyclopediaViewModel(contentService: service)
        let deity = makeDeity(name: "媽祖", alias: "天上聖母", domain: "平安")

        let load = Task { await viewModel.loadIfNeeded() }
        await service.waitUntilFetchStarts()

        XCTAssertEqual(viewModel.loadState, .loading)
        await service.succeed(with: [deity])
        await load.value

        XCTAssertEqual(viewModel.loadState, .loaded)
        XCTAssertEqual(viewModel.deities, [deity])
    }

    func testEmptyResponseProducesLoadedEmptyState() async {
        let viewModel = DeityEncyclopediaViewModel(
            contentService: ImmediateTempleContentService(result: .success([]))
        )

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.loadState, .loaded)
        XCTAssertTrue(viewModel.deities.isEmpty)
        XCTAssertEqual(viewModel.viewState, .empty)
    }

    func testEmptyCatalogCanBeRetried() async {
        let deity = makeDeity(name: "媽祖", alias: "天上聖母", domain: "平安")
        let service = EmptyThenPopulatedTempleContentService(deity: deity)
        let viewModel = DeityEncyclopediaViewModel(contentService: service)

        await viewModel.loadIfNeeded()
        XCTAssertEqual(viewModel.viewState, .empty)

        await viewModel.retry()

        XCTAssertEqual(viewModel.viewState, .loaded([deity]))
        let fetchCount = await service.fetchCount
        XCTAssertEqual(fetchCount, 2)
    }

    func testErrorResponseProducesFailedState() async {
        let viewModel = DeityEncyclopediaViewModel(
            contentService: ImmediateTempleContentService(result: .failure(TestError.fetchFailed))
        )

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.loadState, .failed)
        XCTAssertTrue(viewModel.deities.isEmpty)
    }

    func testSearchMatchesNameAliasAndDomainAndTrimsWhitespace() async {
        let mazu = makeDeity(name: "媽祖", alias: "天上聖母", domain: "航海平安")
        let yueLao = makeDeity(name: "月老", alias: "月下老人", domain: "姻緣和合")
        let viewModel = DeityEncyclopediaViewModel(
            contentService: ImmediateTempleContentService(result: .success([mazu, yueLao]))
        )
        await viewModel.loadIfNeeded()

        viewModel.searchText = "  媽祖  "
        XCTAssertEqual(viewModel.viewState, .loaded([mazu]))

        viewModel.searchText = "月下"
        XCTAssertEqual(viewModel.viewState, .loaded([yueLao]))

        viewModel.searchText = "平安"
        XCTAssertEqual(viewModel.viewState, .loaded([mazu]))

        viewModel.searchText = "  不存在  "
        XCTAssertEqual(viewModel.trimmedSearchText, "不存在")
        XCTAssertEqual(viewModel.viewState, .noSearchResults)
    }

    func testEmptyCatalogTakesPrecedenceOverSearchNoResults() async {
        let viewModel = DeityEncyclopediaViewModel(
            contentService: ImmediateTempleContentService(result: .success([]))
        )
        viewModel.searchText = "媽祖"

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.viewState, .empty)
    }

    func testReentryAfterCallerCancellationSharesOneFetch() async {
        let service = SuspendingTempleContentService()
        let viewModel = DeityEncyclopediaViewModel(contentService: service)

        let firstLoad = Task { await viewModel.loadIfNeeded() }
        await service.waitUntilFetchStarts()
        firstLoad.cancel()
        let secondLoad = Task { await viewModel.loadIfNeeded() }
        await Task.yield()

        let fetchCountWhileLoading = await service.fetchCount
        XCTAssertEqual(fetchCountWhileLoading, 1)
        await service.succeed(with: [])
        await firstLoad.value
        await secondLoad.value

        XCTAssertEqual(viewModel.loadState, .loaded)
        let finalFetchCount = await service.fetchCount
        XCTAssertEqual(finalFetchCount, 1)
    }

    private func makeDeity(name: String, alias: String?, domain: String) -> Deity {
        Deity(
            id: UUID(),
            name: name,
            alias: alias,
            origin: "由來",
            domain: domain,
            howToWorship: "參拜方式",
            imageName: "test"
        )
    }
}

private enum TestError: Error {
    case fetchFailed
}

private struct ImmediateTempleContentService: TempleContentServicing {
    let result: Result<[Deity], Error>

    func fetchTemple() async throws -> Temple {
        throw TestError.fetchFailed
    }

    func fetchDeities() async throws -> [Deity] {
        try result.get()
    }

    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature] {
        throw TestError.fetchFailed
    }
}

private actor SuspendingTempleContentService: TempleContentServicing {
    private(set) var fetchCount = 0
    private var continuation: CheckedContinuation<[Deity], Error>?

    func fetchTemple() async throws -> Temple {
        throw TestError.fetchFailed
    }

    func fetchDeities() async throws -> [Deity] {
        fetchCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature] {
        throw TestError.fetchFailed
    }

    func waitUntilFetchStarts() async {
        while fetchCount == 0 {
            await Task.yield()
        }
    }

    func succeed(with deities: [Deity]) {
        continuation?.resume(returning: deities)
        continuation = nil
    }
}

private actor EmptyThenPopulatedTempleContentService: TempleContentServicing {
    private(set) var fetchCount = 0
    private let deity: Deity

    init(deity: Deity) {
        self.deity = deity
    }

    func fetchTemple() async throws -> Temple {
        throw TestError.fetchFailed
    }

    func fetchDeities() async throws -> [Deity] {
        fetchCount += 1
        return fetchCount == 1 ? [] : [deity]
    }

    func fetchArchitectureFeatures() async throws -> [ArchitectureFeature] {
        throw TestError.fetchFailed
    }
}
