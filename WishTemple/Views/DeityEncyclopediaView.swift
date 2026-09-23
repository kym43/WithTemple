import SwiftUI

@MainActor
final class DeityEncyclopediaViewModel: ObservableObject {
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    enum ViewState: Equatable {
        case loading
        case empty
        case noSearchResults
        case loaded([Deity])
        case failed
    }

    @Published private(set) var loadState = LoadState.loading
    @Published private(set) var deities: [Deity] = []
    @Published var searchText = ""

    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private let contentService: any TempleContentServicing
    private var activeLoad: (id: UUID, task: Task<[Deity], Error>)?

    init(contentService: any TempleContentServicing) {
        self.contentService = contentService
    }

    var viewState: ViewState {
        switch loadState {
        case .loading:
            return .loading
        case .failed:
            return .failed
        case .loaded where deities.isEmpty:
            return .empty
        case .loaded:
            let filteredDeities = deities(matching: trimmedSearchText)
            return filteredDeities.isEmpty ? .noSearchResults : .loaded(filteredDeities)
        }
    }

    private func deities(matching query: String) -> [Deity] {
        guard !query.isEmpty else { return deities }

        return deities.filter { deity in
            [deity.name, deity.alias, deity.domain]
                .compactMap { $0 }
                .contains { $0.localizedStandardContains(query) }
        }
    }

    func loadIfNeeded() async {
        guard loadState == .loading, deities.isEmpty else { return }
        await loadDeities()
    }

    func retry() async {
        await loadDeities()
    }

    private func loadDeities() async {
        if let activeLoad {
            await resolve(activeLoad.task, id: activeLoad.id)
            return
        }

        loadState = .loading
        let id = UUID()
        let task = Task { [contentService] in
            try await contentService.fetchDeities()
        }
        activeLoad = (id, task)
        await resolve(task, id: id)
    }

    private func resolve(_ task: Task<[Deity], Error>, id: UUID) async {
        let result = await task.result
        guard activeLoad?.id == id else { return }

        activeLoad = nil
        switch result {
        case let .success(deities):
            self.deities = deities
            loadState = .loaded
        case .failure:
            loadState = .failed
        }
    }
}

struct DeityEncyclopediaView: View {
    @StateObject private var viewModel: DeityEncyclopediaViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(contentService: any TempleContentServicing = MockTempleContentService()) {
        _viewModel = StateObject(
            wrappedValue: DeityEncyclopediaViewModel(contentService: contentService)
        )
    }

    private var gridColumns: [GridItem] {
        guard horizontalSizeClass == .regular else {
            return [GridItem(.flexible())]
        }

        return [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading:
                    ProgressView("encyclopedia_loading")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty:
                    ContentUnavailableView {
                        Label("encyclopedia_empty_title", systemImage: "books.vertical")
                    } description: {
                        Text("encyclopedia_empty_description")
                    } actions: {
                        retryButton
                    }
                case .noSearchResults:
                    ContentUnavailableView.search(text: viewModel.trimmedSearchText)
                case let .loaded(deities):
                    encyclopediaContent(deities: deities)
                case .failed:
                    ContentUnavailableView {
                        Label("encyclopedia_error_title", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text("encyclopedia_error_description")
                    } actions: {
                        retryButton
                    }
                }
            }
                .navigationTitle("encyclopedia_tab")
                .navigationDestination(for: Deity.self) { deity in
                    DeityDetailView(deity: deity)
                }
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "encyclopedia_search_prompt"
                )
                .task {
                    await viewModel.loadIfNeeded()
                }
        }
    }

    private var retryButton: some View {
        Button("retry_action") {
            Task { await viewModel.retry() }
        }
        .buttonStyle(.borderedProminent)
    }

    private func encyclopediaContent(deities: [Deity]) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                EncyclopediaHeroView()

                LazyVGrid(
                    columns: gridColumns,
                    spacing: 16
                ) {
                    ForEach(deities) { deity in
                        NavigationLink(value: deity) {
                            DeityCardView(deity: deity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
            .frame(maxWidth: 1100)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

}

private struct EncyclopediaHeroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2.weight(.semibold))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("encyclopedia_intro_title")
                        .font(.title2.bold())
                    Text("encyclopedia_intro_description")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.88))
                }
            }

            Label("encyclopedia_review_status", systemImage: "checkmark.seal")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(.white.opacity(0.15), in: Capsule())
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.19, green: 0.16, blue: 0.48), Color(red: 0.72, green: 0.20, blue: 0.34)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct DeityCardView: View {
    let deity: Deity

    var body: some View {
        HStack(spacing: 16) {
            Image(deity.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.primary.opacity(0.10), lineWidth: 1)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(deity.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }

                if let alias = deity.alias {
                    Text(alias)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(deity.domain)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.primary.opacity(0.06), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("encyclopedia_open_detail_hint"))
    }
}

private struct DeityDetailView: View {
    let deity: Deity

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(deity.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 440)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.primary.opacity(0.10), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.12), radius: 14, y: 8)
                        .accessibilityHidden(true)

                    Text(deity.name)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)

                    if let alias = deity.alias {
                        Text(alias)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Label("encyclopedia_review_status", systemImage: "checkmark.seal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                .frame(maxWidth: .infinity)

                DeityDetailSection(
                    title: "deity_origin_title",
                    systemImage: "scroll",
                    content: deity.origin
                )
                DeityDetailSection(
                    title: "deity_domain_title",
                    systemImage: "sparkles",
                    content: deity.domain
                )
                DeityDetailSection(
                    title: "deity_worship_title",
                    systemImage: "hands.and.sparkles",
                    content: deity.howToWorship
                )

                if let sourceName = deity.sourceName, let sourceURL = deity.sourceURL {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("encyclopedia_source_title", systemImage: "link")
                            .font(.headline)

                        Link(destination: sourceURL) {
                            Label(sourceName, systemImage: "arrow.up.right.square")
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        }
                    }
                    .padding(18)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                Label("encyclopedia_cultural_note", systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(20)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(deity.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DeityDetailSection: View {
    let title: LocalizedStringKey
    let systemImage: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    DeityEncyclopediaView()
}
