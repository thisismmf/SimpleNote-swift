import SwiftUI

struct LogoutConfirmSheet: View {
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Log Out").font(.headline)
            Text("Are you sure you want to log out from the application?")
            HStack {
                OutlinedButton(title: "Cancel", action: onCancel)
                PrimaryButton(title: "Yes", action: onConfirm)
            }
        }
        .padding()
    }
}

#Preview {
    LogoutConfirmSheet(onConfirm: {}, onCancel: {})
}
