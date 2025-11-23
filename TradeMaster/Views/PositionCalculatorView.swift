import SwiftUI
import SwiftData

struct PositionCalculatorView: View {
    @Environment(\.modelContext) private var context
    @Query private var settings: [UserSettings]

    @State private var instrument: String = "BTCUSD"
    @State private var entryPrice: Double = 30000
    @State private var stopLossPrice: Double = 28500
    @State private var takeProfitInputs: [String] = ["32000", "34000", "36000"]
    @State private var dcaEntries: [DCAEntry] = [DCAEntry(entryPrice: 30000, allocationPercent: 100)]
    @State private var outcome: Trade.Outcome = .tp1
    @State private var showAddedToast = false
    @State private var showSettings = false
    @FocusState private var isAnyFieldFocused: Bool

    private var riskPercent: Double { settings.first?.riskPercent ?? 1.0 }
    private var currentCapital: Double { settings.first?.currentCapital ?? 0 }
    private var capitalGoal: Double { settings.first?.capitalGoal ?? 0 }

    private var normalizedDCA: [DCAEntry] {
        let total = dcaEntries.reduce(0) { $0 + max($1.allocationPercent, 0) }
        guard total > 0 else { return dcaEntries }
        return dcaEntries.map { entry in
            let percent = entry.allocationPercent / total * 100
            return DCAEntry(entryPrice: entry.entryPrice, allocationPercent: percent)
        }
    }

    private var riskAmount: Double { currentCapital * (riskPercent / 100) }

    private var perEntryUnits: [(DCAEntry, Double)] {
        normalizedDCA.map { entry in
            let distance = abs(entry.entryPrice - stopLossPrice)
            guard distance > 0 else { return (entry, 0) }
            let allocRisk = riskAmount * (entry.allocationPercent / 100)
            return (entry, allocRisk / distance)
        }
    }

    private var totalUnits: Double { perEntryUnits.reduce(0) { $0 + $1.1 } }

    private var averageEntry: Double {
        guard totalUnits > 0 else { return entryPrice }
        let weighted = perEntryUnits.reduce(0) { $0 + ($1.1 * $1.0.entryPrice) }
        return weighted / totalUnits
    }

    private var takeProfitValues: [Double] {
        takeProfitInputs.compactMap { Double($0.replacingOccurrences(of: ",", with: ".")) }
    }

    private var computedPnL: Double {
        switch outcome {
        case .tp1, .tp2, .tp3:
            let index = outcome == .tp1 ? 0 : outcome == .tp2 ? 1 : 2
            guard takeProfitValues.indices.contains(index) else { return 0 }
            let tp = takeProfitValues[index]
            return totalUnits * (tp - averageEntry)
        case .sl:
            return totalUnits * (stopLossPrice - averageEntry)
        case .be:
            return 0
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressHeaderView(currentCapital: currentCapital, goal: capitalGoal)

                    VStack(alignment: .leading, spacing: 12) {
                        header
                        capitalInfo
                        instrumentSection
                        dcaSection
                        tpSection
                        outcomePicker
                        hideKeyboardButton
                    }
                    .padding()
                    .cardStyle()

                    resultCard

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
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Ustawienia", systemImage: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(isPresented: $showSettings)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Parametry ryzyka")
                .font(.headline)
            Text("Kapitał i ryzyko pobierane są z ustawień i automatycznie aktualizowane po każdej transakcji.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var capitalInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Bieżący kapitał", systemImage: "creditcard.fill")
                .foregroundStyle(.secondary)
            Text(Formatters.currencyString(from: currentCapital))
                .font(.title2.bold())
            Label("Ryzyko na trade", systemImage: "percent")
                .foregroundStyle(.secondary)
            Text(String(format: "%.2f%% (\(Formatters.currencyString(from: riskAmount)) )", riskPercent))
                .font(.title3.weight(.semibold))
        }
    }

    private var instrumentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wejście")
                .font(.headline)
            TextField("Instrument", text: $instrument)
                .textFieldStyle(.roundedBorder)
                .focused($isAnyFieldFocused)
            numericField(title: "Entry", value: $entryPrice)
            numericField(title: "Stop Loss", value: $stopLossPrice)
        }
    }

    private var dcaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DCA / podziały wejścia")
                    .font(.headline)
                Spacer()
                Button {
                    dcaEntries.append(DCAEntry(entryPrice: entryPrice, allocationPercent: max(0, 100 - dcaEntries.reduce(0) { $0 + $1.allocationPercent })))
                } label: {
                    Label("Dodaj", systemImage: "plus")
                }
            }

            ForEach(Array(dcaEntries.enumerated()), id: \.offset) { index, entry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Wejście \(index + 1)")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        if dcaEntries.count > 1 {
                            Button(role: .destructive) { dcaEntries.remove(at: index) } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                    HStack(spacing: 12) {
                        numericField(title: "Entry", value: binding(for: \DCAEntry.entryPrice, at: index))
                        numericField(title: "%", value: binding(for: \DCAEntry.allocationPercent, at: index))
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground).opacity(0.25))
                .cornerRadius(12)
            }
        }
    }

    private var tpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Take Profit")
                    .font(.headline)
                Spacer()
                Button {
                    takeProfitInputs.append("")
                } label: {
                    Label("Dodaj TP", systemImage: "plus.circle")
                }
            }
            ForEach(takeProfitInputs.indices, id: \.self) { index in
                HStack {
                    Text("TP \(index + 1)")
                    TextField("0", text: Binding(
                        get: { takeProfitInputs[index] },
                        set: { takeProfitInputs[index] = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($isAnyFieldFocused)
                    if takeProfitInputs.count > 1 {
                        Button(role: .destructive) {
                            takeProfitInputs.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                    }
                }
            }
        }
    }

    private var outcomePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zdarzenie")
                .font(.headline)
            Picker("Wynik", selection: $outcome) {
                ForEach(Trade.Outcome.allCases) { outcome in
                    Text(outcome.rawValue).tag(outcome)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var hideKeyboardButton: some View {
        HStack {
            Spacer()
            Button {
                hideKeyboard()
            } label: {
                Label("Schowaj klawiaturę", systemImage: "keyboard.chevron.compact.down")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var resultCard: some View {
        VStack(spacing: 12) {
            Text("Wynik pozycji")
                .font(.headline)
            Text(String(format: "%.4f jednostek", totalUnits))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(LinearGradient.tradeMaster)
            Text("Średnie wejście: \(Formatters.currencyString(from: averageEntry))")
                .foregroundStyle(.secondary)
            Text("Potencjalny wynik: \(Formatters.currencyString(from: computedPnL))")
                .foregroundStyle(computedPnL >= 0 ? .green : .red)

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
    }

    private func numericField(title: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundStyle(.secondary)
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .focused($isAnyFieldFocused)
        }
    }

    private func binding(for keyPath: WritableKeyPath<DCAEntry, Double>, at index: Int) -> Binding<Double> {
        Binding<Double>(
            get: { dcaEntries[index][keyPath: keyPath] },
            set: { dcaEntries[index][keyPath: keyPath] = $0 }
        )
    }

    private func addToJournal() {
        guard let settings = settings.first else { return }
        let trade = Trade(
            instrument: instrument,
            totalUnits: totalUnits,
            entryPrice: entryPrice,
            stopLoss: stopLossPrice,
            takeProfits: takeProfitValues,
            dcaPlan: dcaEntries,
            outcome: outcome,
            profitLoss: computedPnL,
            averageEntry: averageEntry,
            riskPercentUsed: riskPercent,
            capitalAtEntry: currentCapital
        )
        context.insert(trade)
        settings.currentCapital += computedPnL
        try? context.save()
        withAnimation { showAddedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showAddedToast = false }
        }
    }
}
