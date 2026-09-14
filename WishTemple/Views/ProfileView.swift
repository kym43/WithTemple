import SwiftUI

/// Phase 1 placeholder for personal ritual history, notification settings, and about-the-temple info.
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("profile_placeholder_title", systemImage: "person")
                .navigationTitle("profile_tab")
        }
    }
}

#Preview {
    ProfileView()
}
