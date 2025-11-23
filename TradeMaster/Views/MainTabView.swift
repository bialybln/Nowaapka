import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Trade.date, order: .reverse) private var trades: [Trade]
    @Query private var settings: [UserSettings]
    @Query private var stats: [AccountStats]

    var body: some View {
        TabView {
            PositionCalculatorView()
                .tabItem { Label("Kalkulator", systemImage: "slider.horizontal.3") }

            AccountStatsView(accountStats: stats.first, settings: settings.first, trades: trades)
                .tabItem { Label("Statystyki", systemImage: "chart.line.uptrend.xyaxis") }

            TradeJournalView(trades: trades)
                .tabItem { Label("Dziennik", systemImage: "list.bullet.rectangle") }
        }
        .onAppear {
            if trades.isEmpty { SampleDataService.bootstrap(context: context) }
        }
    }
}
