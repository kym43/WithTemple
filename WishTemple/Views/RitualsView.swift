import SwiftUI

/// Phase 1 placeholder for 拜拜 / 安太歲 / 點光明燈 entry points and history.
struct RitualsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("rituals_placeholder_title", systemImage: "hands.sparkles")
                .navigationTitle("rituals_tab")
        }
    }
}

#Preview {
    RitualsView()
}
