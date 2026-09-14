import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("home_tab", systemImage: "building.columns") }

            RitualsView()
                .tabItem { Label("rituals_tab", systemImage: "hands.sparkles") }

            DeityEncyclopediaView()
                .tabItem { Label("encyclopedia_tab", systemImage: "book") }

            ProfileView()
                .tabItem { Label("profile_tab", systemImage: "person") }
        }
    }
}

#Preview {
    MainTabView()
}
