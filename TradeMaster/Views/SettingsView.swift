import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [UserSettings]
    @Binding var isPresented: Bool

    @State private var capitalGoal: Double = 0
    @State private var initialCapital: Double = 0
    @State private var currentCapital: Double = 0
    @State private var riskPercent: Double = 1.0

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Kapitał")) {
                    NumberField(title: "Cel kapitału", value: $capitalGoal)
                    NumberField(title: "Kapitał początkowy", value: $initialCapital)
                    NumberField(title: "Bieżący kapitał", value: $currentCapital)
                }

                Section(header: Text("Ryzyko")) {
                    NumberField(title: "Ryzyko %", value: $riskPercent)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Ustawienia")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Anuluj") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") { save() }
                }
            }
            .onAppear(perform: load)
        }
        .preferredColorScheme(.dark)
    }

    private func load() {
        let settings = settingsList.first
        capitalGoal = settings?.capitalGoal ?? 0
        initialCapital = settings?.initialCapital ?? 0
        currentCapital = settings?.currentCapital ?? 0
        riskPercent = settings?.riskPercent ?? 1.0
    }

    private func save() {
        if let settings = settingsList.first {
            settings.capitalGoal = capitalGoal
            settings.initialCapital = initialCapital
            settings.currentCapital = currentCapital
            settings.riskPercent = riskPercent
        } else {
            let newSettings = UserSettings(capitalGoal: capitalGoal, initialCapital: initialCapital, currentCapital: currentCapital, riskPercent: riskPercent, preferredAuthMethod: .biometric)
            context.insert(newSettings)
        }
        try? context.save()
        isPresented = false
    }
}

private struct NumberField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", value: $value, format: .number)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
        }
    }
}
