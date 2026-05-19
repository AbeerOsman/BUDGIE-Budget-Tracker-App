import SwiftUI
import SwiftData

@main
struct BUDGIEApp: App {
    @State private var categoriesViewModel = CategoriesViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Income.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Splash()
                .environment(categoriesViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
