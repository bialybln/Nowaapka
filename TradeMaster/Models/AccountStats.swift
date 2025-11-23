import Foundation
import SwiftData

@Model
final class AccountStats {
    var winRate: Double
    var averageRR: Double
    var totalProfit: Double
    var totalLoss: Double

    init(winRate: Double = 0.0, averageRR: Double = 0.0, totalProfit: Double = 0.0, totalLoss: Double = 0.0) {
        self.winRate = winRate
        self.averageRR = averageRR
        self.totalProfit = totalProfit
        self.totalLoss = totalLoss
    }
}
