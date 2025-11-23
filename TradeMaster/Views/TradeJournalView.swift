import SwiftUI
import SwiftData

struct TradeJournalView: View {
    @Environment(\.modelContext) private var context
    @State private var sortDescending = true
    @State private var filter: Trade.Outcome? = nil
    @State private var selectedTrade: Trade?

    let trades: [Trade]

    var filteredTrades: [Trade] {
        let sorted = trades.sorted { sortDescending ? $0.date > $1.date : $0.date < $1.date }
        guard let filter else { return sorted }
        return sorted.filter { $0.outcome == filter }
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Sortowanie", selection: $sortDescending) {
                    Text("Najnowsze").tag(true)
                    Text("Najstarsze").tag(false)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                ScrollView {
                    LazyVStack(spacing: 12) {
                        filterChips
                        ForEach(filteredTrades) { trade in
                            TradeRowView(trade: trade)
                                .onTapGesture { selectedTrade = trade }
                                .contextMenu {
                                    Button("Usuń", role: .destructive) { context.delete(trade) }
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Dziennik transakcji")
            .sheet(item: $selectedTrade) { trade in
                TradeDetailView(trade: trade)
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                chip(title: "Wszystkie", isActive: filter == nil) { filter = nil }
                ForEach(Trade.Outcome.allCases) { outcome in
                    chip(title: outcome.rawValue, isActive: filter == outcome) { filter = outcome }
                }
            }
        }
    }

    private func chip(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(isActive ? LinearGradient.tradeMaster : Color(uiColor: .secondarySystemBackground))
                .foregroundStyle(isActive ? .white : .primary)
                .cornerRadius(16)
                .shadow(radius: isActive ? 8 : 0)
        }
        .buttonStyle(.plain)
    }
}
