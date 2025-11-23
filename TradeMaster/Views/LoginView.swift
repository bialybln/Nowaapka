import SwiftUI
import LocalAuthentication
import SwiftData

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Environment(\.modelContext) private var context
    @Query private var settings: [UserSettings]
    @State private var pin: String = ""
    @State private var errorMessage: String?
    @State private var useBiometrics = true

    private var storedSettings: UserSettings? { settings.first }

    var body: some View {
        ZStack {
            LinearGradient.tradeMaster.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 12) {
                    Text("TradeMaster")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("Bezpieczny dostęp do Twojego tradingu")
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
                .background(.ultraThinMaterial.opacity(0.35))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.18), radius: 20)
                .scaleEffect(1.02)
                .animation(.easeInOut(duration: 0.6), value: pin)

                VStack(spacing: 16) {
                    SecureField("PIN lub hasło", text: $pin)
                        .textContentType(.password)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.12), radius: 14)

                    Toggle("Użyj Face ID / Touch ID", isOn: $useBiometrics)
                        .tint(.white)
                        .foregroundStyle(.white)

                    Button(action: login) {
                        HStack {
                            Image(systemName: "lock.open.fill")
                            Text("Zaloguj")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.9))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .white.opacity(0.35), radius: 10)

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.white)
                            .padding(.top, 8)
                    }
                }
                .padding()
                .background(.ultraThinMaterial.opacity(0.45))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                Spacer()
            }
        }
        .onAppear {
            Task { await biometricsIfNeeded() }
        }
    }

    func biometricsIfNeeded() async {
        guard useBiometrics, let storedSettings else { return }
        if storedSettings.preferredAuthMethod == .biometric {
            let success = await BiometricAuthService.shared.authenticateUser()
            await MainActor.run {
                isAuthenticated = success
            }
        }
    }

    func login() {
        guard let storedSettings else { return }
        if let account = storedSettings.storedPasswordIdentifier,
           let password = KeychainService.shared.password(for: account),
           password == pin {
            isAuthenticated = true
            errorMessage = nil
        } else if storedSettings.storedPasswordIdentifier == nil {
            let identifier = UUID().uuidString
            storedSettings.storedPasswordIdentifier = identifier
            KeychainService.shared.save(password: pin, account: identifier)
            try? context.save()
            isAuthenticated = true
        } else {
            errorMessage = "Niepoprawne hasło"
        }
    }
}
