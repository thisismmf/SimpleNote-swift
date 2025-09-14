import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundColor(.white)
                .background(Color.notesPrimary)
                .cornerRadius(12)
        }
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "Continue", action: {})
    }.padding()
}
