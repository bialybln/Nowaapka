import SwiftUI
import SwiftData

@main
struct TradeMasterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Trade.self, UserSettings.self, AccountStats.self])
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var users: [UserSettings]
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                MainTabView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .task {
            if users.isEmpty {
                let settings = UserSettings(capitalGoal: 20000, initialCapital: 10000, currentCapital: 10000, riskPercent: 1.0, preferredAuthMethod: .biometric)
                context.insert(settings)
                try? context.save()
            }
        }
    }
}
