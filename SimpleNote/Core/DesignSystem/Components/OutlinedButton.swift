import SwiftUI

struct OutlinedButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundColor(.notesPrimary)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.notesPrimary, lineWidth: 1))
        }
    }
}

#Preview {
    OutlinedButton(title: "Secondary", action: {})
        .padding()
}
