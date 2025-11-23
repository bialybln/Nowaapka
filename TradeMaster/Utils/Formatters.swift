import Foundation
import SwiftUI

enum Formatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func currencyString(from value: Double) -> String {
        currency.string(from: NSNumber(value: value)) ?? "$0"
    }

    static func percentString(from value: Double) -> String {
        String(format: "%.1f%%", value)
    }
}

extension LinearGradient {
    static var tradeMaster: LinearGradient {
        LinearGradient(colors: [Color.purple.opacity(0.9), Color.blue, Color.mint], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(.thinMaterial)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
}
