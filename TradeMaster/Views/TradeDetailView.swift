import SwiftUI

struct TradeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State var trade: Trade

    var body: some View {
        NavigationStack {
            Form {
                Section("Szczegóły") {
                    TextField("Instrument", text: $trade.instrument)
                    Stepper(value: $trade.totalUnits, in: 0...100000, step: 0.0001) {
                        Text("Jednostki: \(trade.totalUnits, specifier: "%.4f")")
                    }
                    TextField("Entry", value: $trade.entryPrice, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Stop Loss", value: $trade.stopLoss, format: .number)
                        .keyboardType(.decimalPad)
                    DatePicker("Data", selection: $trade.date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Wynik", selection: $trade.outcome) {
                        ForEach(Trade.Outcome.allCases) { outcome in
                            Text(outcome.rawValue).tag(outcome)
                        }
                    }
                    TextField("Kwota", value: $trade.profitLoss, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Take Profit") {
                    ForEach(Array(trade.takeProfits.enumerated()), id: \.offset) { index, _ in
                        TextField("TP \(index + 1)", value: Binding(
                            get: { trade.takeProfits[index] },
                            set: { trade.takeProfits[index] = $0 }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Edytuj trade")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") { save() }
                }
            }
        }
    }

    private func save() {
        context.insert(trade)
        try? context.save()
        dismiss()
    }
}
