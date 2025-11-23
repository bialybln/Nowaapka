import Foundation
import SwiftData

@Model
final class Trade {
    enum Outcome: String, Codable, CaseIterable, Identifiable {
        case tp = "Take Profit"
        case sl = "Stop Loss"
        case be = "Break Even"

        var id: String { rawValue }
    }

    var instrument: String
    var lotSize: Double
    var date: Date
    var outcome: Outcome
    var profitLoss: Double

    init(instrument: String, lotSize: Double, date: Date = .now, outcome: Outcome, profitLoss: Double) {
        self.instrument = instrument
        self.lotSize = lotSize
        self.date = date
        self.outcome = outcome
        self.profitLoss = profitLoss
    }
}
