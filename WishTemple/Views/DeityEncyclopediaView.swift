import SwiftUI

/// Phase 1 placeholder for the deity encyclopedia and the temple architecture encyclopedia sub-section.
struct DeityEncyclopediaView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("encyclopedia_placeholder_title", systemImage: "book")
                .navigationTitle("encyclopedia_tab")
        }
    }
}

#Preview {
    DeityEncyclopediaView()
}
