import SwiftUI
import Charts

struct AccountStatsView: View {
    let accountStats: AccountStats?
    let settings: UserSettings?
    let trades: [Trade]

    var cumulativePoints: [(Date, Double)] {
        var running: Double = settings?.initialCapital ?? 0
        return trades.sorted { $0.date < $1.date }.map { trade in
            running += trade.profitLoss
            return (trade.date, running)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProgressHeaderView(currentCapital: settings?.currentCapital ?? 0, goal: settings?.capitalGoal ?? 0)

                HStack(spacing: 12) {
                    statCard(title: "Bieżący kapitał", value: Formatters.currencyString(from: settings?.currentCapital ?? 0), icon: "creditcard.fill")
                    statCard(title: "Cel kapitału", value: Formatters.currencyString(from: settings?.capitalGoal ?? 0), icon: "target")
                }

                HStack(spacing: 12) {
                    statCard(title: "% skuteczności", value: Formatters.percentString(from: accountStats?.winRate ?? 0), icon: "hands.clap.fill")
                    statCard(title: "Średnie R:R", value: String(format: "%.2f", accountStats?.averageRR ?? 0), icon: "arrow.triangle.branch")
                }

                HStack(spacing: 12) {
                    statCard(title: "Łączne zyski", value: Formatters.currencyString(from: accountStats?.totalProfit ?? 0), icon: "arrow.up.right.circle.fill")
                    statCard(title: "Łączne straty", value: Formatters.currencyString(from: accountStats?.totalLoss ?? 0), icon: "arrow.down.right.circle.fill")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Wzrost kapitału")
                        .font(.headline)
                    Chart {
                        ForEach(Array(cumulativePoints.enumerated()), id: \.[0]) { index, point in
                            LineMark(
                                x: .value("Data", point.0),
                                y: .value("Kapitał", point.1)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(LinearGradient.tradeMaster)
                            AreaMark(
                                x: .value("Data", point.0),
                                yStart: .value("Kapitał", settings?.initialCapital ?? 0),
                                yEnd: .value("Kapitał", point.1)
                            )
                            .foregroundStyle(.linearGradient(colors: [.blue.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                        }
                    }
                    .frame(height: 220)
                    .cardStyle()
                }
            }
            .padding()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Statystyki konta")
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.14, green: 0.14, blue: 0.18))
        .cornerRadius(14)
    }
}
