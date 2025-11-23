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
        LinearGradient(colors: [Color(#colorLiteral(red: 0.325, green: 0.0, blue: 0.725, alpha: 1)), Color(#colorLiteral(red: 0.129, green: 0.4, blue: 0.918, alpha: 1)), Color(#colorLiteral(red: 0.0, green: 0.78, blue: 0.58, alpha: 1))], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
