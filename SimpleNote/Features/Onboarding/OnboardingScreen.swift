import SwiftUI

struct OnboardingScreen: View {
    var onGetStarted: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "scribble.variable").font(.system(size: 64))
                .foregroundColor(.notesPrimary)
            Text("Jot Down anything you want to achieve, today or in the future")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            PrimaryButton(title: "Let's Get Started", action: onGetStarted)
                .padding(.horizontal, 24)
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnboardingScreen(onGetStarted: {})
}
