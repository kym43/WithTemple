import SwiftUI
import SwiftData

@main
struct WishTempleApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try WishPersistence.makeModelContainer()
        } catch {
            fatalError(
                "Unable to configure the local wish store: \(String(reflecting: error))"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
}
