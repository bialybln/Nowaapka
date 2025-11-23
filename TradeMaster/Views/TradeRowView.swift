import SwiftUI

struct TradeRowView: View {
    let trade: Trade

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(trade.instrument)
                    .font(.headline)
                Text(trade.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.4f jednostek", trade.totalUnits))
                    .font(.subheadline.weight(.semibold))
                Text(outcomeEmoji + " " + trade.outcome.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Formatters.currencyString(from: trade.profitLoss))
                    .foregroundStyle(trade.profitLoss >= 0 ? .green : .red)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(red: 0.14, green: 0.14, blue: 0.18))
        .cornerRadius(14)
    }

    private var outcomeEmoji: String {
        switch trade.outcome {
        case .tp1, .tp2, .tp3: return "✅"
        case .sl: return "❌"
        case .be: return "🟦"
        }
    }
}
