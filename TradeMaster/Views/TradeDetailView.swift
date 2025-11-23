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
                    Stepper(value: $trade.lotSize, in: 0...100, step: 0.01) {
                        Text("Lot: \(trade.lotSize, specifier: "%.2f")")
                    }
                    DatePicker("Data", selection: $trade.date, displayedComponents: [.date, .hourAndMinute])
                    Picker("Wynik", selection: $trade.outcome) {
                        ForEach(Trade.Outcome.allCases) { outcome in
                            Text(outcome.rawValue).tag(outcome)
                        }
                    }
                    TextField("Kwota", value: $trade.profitLoss, format: .number)
                        .keyboardType(.decimalPad)
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
