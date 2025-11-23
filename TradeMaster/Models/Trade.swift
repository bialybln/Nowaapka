import Foundation
import SwiftData

@Model
final class Trade {
    enum Outcome: String, Codable, CaseIterable, Identifiable {
        case tp1 = "TP1"
        case tp2 = "TP2"
        case tp3 = "TP3"
        case sl = "Stop Loss"
        case be = "Break Even"

        var id: String { rawValue }
    }

    var instrument: String
    var totalUnits: Double
    var entryPrice: Double
    var stopLoss: Double
    @Attribute(.transformable) var takeProfits: [Double]
    @Attribute(.transformable) var dcaPlan: [DCAEntry]
    var date: Date
    var outcome: Outcome
    var profitLoss: Double
    var averageEntry: Double
    var riskPercentUsed: Double
    var capitalAtEntry: Double

    init(instrument: String, totalUnits: Double, entryPrice: Double, stopLoss: Double, takeProfits: [Double] = [], dcaPlan: [DCAEntry] = [], date: Date = .now, outcome: Outcome, profitLoss: Double, averageEntry: Double, riskPercentUsed: Double, capitalAtEntry: Double) {
        self.instrument = instrument
        self.totalUnits = totalUnits
        self.entryPrice = entryPrice
        self.stopLoss = stopLoss
        self.takeProfits = takeProfits
        self.dcaPlan = dcaPlan
        self.date = date
        self.outcome = outcome
        self.profitLoss = profitLoss
        self.averageEntry = averageEntry
        self.riskPercentUsed = riskPercentUsed
        self.capitalAtEntry = capitalAtEntry
    }
}

struct DCAEntry: Codable, Hashable {
    var entryPrice: Double
    var allocationPercent: Double
}
