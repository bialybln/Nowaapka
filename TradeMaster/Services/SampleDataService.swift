import Foundation
import SwiftData

struct SampleDataService {
    static func bootstrap(context: ModelContext) {
        let trades = [
            Trade(instrument: "EURUSD", lotSize: 0.5, date: .now.addingTimeInterval(-86400 * 3), outcome: .tp, profitLoss: 250),
            Trade(instrument: "XAUUSD", lotSize: 0.3, date: .now.addingTimeInterval(-86400 * 2), outcome: .sl, profitLoss: -120),
            Trade(instrument: "GBPJPY", lotSize: 0.8, date: .now.addingTimeInterval(-86400), outcome: .tp, profitLoss: 430)
        ]

        trades.forEach { context.insert($0) }

        let stats = AccountStats(winRate: 65, averageRR: 2.1, totalProfit: 680, totalLoss: 120)
        context.insert(stats)
    }
}
