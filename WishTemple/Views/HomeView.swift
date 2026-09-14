import SwiftUI

/// Phase 1 placeholder: 2D temple + wish tree home scene, tap-through to the RealityKit interior comes in a later phase.
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("home_placeholder_title", systemImage: "building.columns")
                .navigationTitle("home_tab")
        }
    }
}

#Preview {
    HomeView()
}
