import SwiftUI
#if canImport(Lottie)
import Lottie
#endif

struct ProgressHeaderView: View {
    var currentCapital: Double
    var goal: Double

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(currentCapital / goal, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Postęp celu")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(Formatters.currencyString(from: currentCapital))
                        .font(.title.weight(.bold))
                    Text("Cel: \(Formatters.currencyString(from: goal))")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12))
                    Capsule().fill(LinearGradient.tradeMaster)
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.8), value: progress)

                    PocoyoAnimationView()
                        .frame(width: 80, height: 80)
                        .offset(x: max(0, geo.size.width * progress - 40), y: -34)
                        .animation(.easeInOut(duration: 0.8), value: progress)
                }
            }
            .frame(height: 40)
        }
        .padding()
        .background(Color(red: 0.14, green: 0.14, blue: 0.18).opacity(0.9))
        .cornerRadius(18)
    }
}

struct PocoyoAnimationView: View {
    var body: some View {
        #if canImport(Lottie)
        LottieView(animation: .named("pocoyo-progress"))
            .playbackMode(.playing(.toEnd))
        #else
        ZStack {
            Circle()
                .fill(LinearGradient.tradeMaster)
                .frame(width: 80, height: 80)
                .overlay(Text("🕺").font(.largeTitle))
                .shadow(radius: 10)
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 6)
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(LinearGradient.tradeMaster, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: UUID())
                )
        }
        #endif
    }
}
