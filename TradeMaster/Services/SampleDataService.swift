import Foundation
import SwiftData

struct SampleDataService {
    static func bootstrap(context: ModelContext) {
        let trades = [
            Trade(instrument: "BTCUSD", totalUnits: 0.25, entryPrice: 30000, stopLoss: 28500, takeProfits: [32000, 34000, 36000], dcaPlan: [DCAEntry(entryPrice: 30000, allocationPercent: 100)], date: .now.addingTimeInterval(-86400 * 3), outcome: .tp2, profitLoss: 500, averageEntry: 30000, riskPercentUsed: 1.0, capitalAtEntry: 10000),
            Trade(instrument: "ETHUSD", totalUnits: 1.5, entryPrice: 1800, stopLoss: 1700, takeProfits: [1900, 2000], dcaPlan: [DCAEntry(entryPrice: 1800, allocationPercent: 60), DCAEntry(entryPrice: 1750, allocationPercent: 40)], date: .now.addingTimeInterval(-86400 * 2), outcome: .sl, profitLoss: -150, averageEntry: 1780, riskPercentUsed: 1.5, capitalAtEntry: 10000),
            Trade(instrument: "SOLUSD", totalUnits: 20, entryPrice: 22, stopLoss: 20, takeProfits: [24, 26], dcaPlan: [DCAEntry(entryPrice: 22, allocationPercent: 100)], date: .now.addingTimeInterval(-86400), outcome: .tp1, profitLoss: 80, averageEntry: 22, riskPercentUsed: 1.0, capitalAtEntry: 10000)
        ]

        trades.forEach { context.insert($0) }

        let stats = AccountStats(winRate: 65, averageRR: 2.1, totalProfit: 680, totalLoss: 120)
        context.insert(stats)
    }
}
