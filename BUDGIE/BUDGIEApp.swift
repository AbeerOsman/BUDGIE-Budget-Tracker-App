import SwiftUI
import SwiftData

@main
struct BUDGIEApp: App {
    
//    var sharedModelContainer: ModelContainer = {
//        //Models that we have in the app
//        let schema = Schema([
//            User.self,
//            Category.self,
//            Transaction.self,
//            MerchantMapping.self,
//            DailyInsight.self,
//            WeeklyInsight.self,
//            MonthlyInsight.self
//        ] as! [any PersistentModel.Type])
//        
//        let modelConfiguration = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false
//        )
//
//        do {
//            return try ModelContainer(
//                for: schema,
//                configurations: [modelConfiguration]
//            )
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            wasanTestView()
        }
        //.modelContainer(sharedModelContainer)
    }
}
