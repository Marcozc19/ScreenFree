import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var showHeadline = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Animated headline
            VStack(spacing: Theme.Spacing.lg) {
                Text("The average person spends")
                    .font(.system(size: Theme.Typography.xl, weight: Theme.Typography.regular))
                    .foregroundColor(.white.opacity(0.8))

                Text("7 years")
                    .font(.system(size: Theme.Typography.display * 1.5, weight: Theme.Typography.bold))
                    .foregroundColor(.white)

                Text("of their life looking at a phone.")
                    .font(.system(size: Theme.Typography.xl, weight: Theme.Typography.regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .multilineTextAlignment(.center)
            .opacity(showHeadline ? 1 : 0)
            .offset(y: showHeadline ? 0 : 20)

            Spacer()

            // CTA Button
            PrimaryButton(
                title: "Let's be different",
                action: {
                    appState.advanceOnboarding()
                },
                style: .primary
            )
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 20)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.splashBackground)
        .onAppear {
            // Fade in headline
            withAnimation(.easeOut(duration: Theme.Animation.fadeIn)) {
                showHeadline = true
            }

            // Delay button appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Animation.buttonDelay) {
                withAnimation(.easeOut(duration: Theme.Animation.fadeIn)) {
                    showButton = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
        .environment(AppState())
}
