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
                Text(String(format: "%.2f lot", trade.lotSize))
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
        .background(.thinMaterial)
        .cornerRadius(14)
    }

    private var outcomeEmoji: String {
        switch trade.outcome {
        case .tp: return "✅"
        case .sl: return "❌"
        case .be: return "🟦"
        }
    }
}
