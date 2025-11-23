import SwiftUI
import SwiftData

struct PositionCalculatorView: View {
    @Environment(\.modelContext) private var context
    @Query private var settings: [UserSettings]

    @State private var capital: Double = 10000
    @State private var riskPercent: Double = 1.5
    @State private var stopLossPips: Double = 15
    @State private var pipValue: Double = 10
    @State private var instrument: String = "EURUSD"
    @State private var outcome: Trade.Outcome = .tp
    @State private var showAddedToast = false

    private var riskAmount: Double { capital * (riskPercent / 100) }
    private var lotSize: Double {
        guard stopLossPips > 0, pipValue > 0 else { return 0 }
        return (riskAmount) / (stopLossPips * pipValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressHeaderView(currentCapital: settings.first?.currentCapital ?? capital, goal: settings.first?.capitalGoal ?? 20000)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Parametry")
                            .font(.headline)
                        Group {
                            inputField(title: "Kapitał", value: $capital, systemImage: "dollarsign")
                            inputField(title: "Ryzyko %", value: $riskPercent, systemImage: "percent")
                            inputField(title: "Stop loss (pips)", value: $stopLossPips, systemImage: "flag.checkered")
                            inputField(title: "Wartość pipsa", value: $pipValue, systemImage: "waveform")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instrument")
                                .font(.subheadline.weight(.semibold))
                            TextField("np. EURUSD", text: $instrument)
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                        }

                        Picker("Wynik", selection: $outcome) {
                            ForEach(Trade.Outcome.allCases) { outcome in
                                Text(outcome.rawValue).tag(outcome)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .cardStyle()

                    VStack(spacing: 12) {
                        Text("Wynik wolumenu")
                            .font(.headline)
                        Text(String(format: "%.2f lot", lotSize))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient.tradeMaster)
                        Text("Ryzykujesz \(Formatters.currencyString(from: riskAmount)) przy stop loss \(Int(stopLossPips)) pips")
                            .foregroundStyle(.secondary)

                        Button {
                            addToJournal()
                        } label: {
                            Label("Dodaj do dziennika", systemImage: "plus")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient.tradeMaster)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .cardStyle()

                    if showAddedToast {
                        Label("Zapisano w dzienniku", systemImage: "checkmark.circle.fill")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(12)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding()
            }
            .navigationTitle("Kalkulator pozycji")
            .background(Color(.systemGroupedBackground))
        }
    }

    private func inputField(title: String, value: Binding<Double>, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .foregroundStyle(.secondary)
            HStack {
                TextField("0", value: value, format: .number)
                    .keyboardType(.decimalPad)
                Spacer()
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    private func addToJournal() {
        let profitLoss = lotSize * stopLossPips * pipValue * (outcome == .sl ? -1 : 1)
        let trade = Trade(instrument: instrument, lotSize: lotSize, outcome: outcome, profitLoss: profitLoss)
        context.insert(trade)
        if let settings = settings.first {
            settings.currentCapital += profitLoss
        }
        withAnimation { showAddedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showAddedToast = false }
        }
    }
}
