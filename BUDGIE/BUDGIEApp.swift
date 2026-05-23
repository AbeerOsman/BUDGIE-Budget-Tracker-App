import SwiftUI
import SwiftData

@main
struct BUDGIEApp: App {
    @State private var categoriesViewModel = CategoriesViewModel()
    @State private var appLockManager = AppLockManager()
    @State private var appSessionController = AppSessionController()
    @Environment(\.scenePhase) private var scenePhase

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
            ZStack {
                Splash()
                    .id(appSessionController.rootSessionID)

                if appLockManager.isEnabled && !appLockManager.isUnlocked {
                    AppLockView()
                        .transition(.opacity)
                }
            }
            .environment(categoriesViewModel)
            .environment(appLockManager)
            .environment(appSessionController)
            .animation(.easeInOut(duration: 0.2), value: appLockManager.isUnlocked)
            .onAppear {
                BudgieNotificationService.shared.requestAuthorizationIfNeeded()
                if appLockManager.isEnabled {
                    appLockManager.isUnlocked = false
                    Task { await appLockManager.unlockIfNeeded() }
                } else {
                    appLockManager.isUnlocked = true
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background, .inactive:
                    appLockManager.lockIfEnabled()
                case .active:
                    Task { await appLockManager.unlockIfNeeded() }
                @unknown default:
                    break
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
