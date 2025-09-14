import SwiftUI

struct ModalDialog: View {
    var title: String
    var message: String
    var primary: (String, () -> Void)
    var secondary: (String, () -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text(title).font(.headline)
            Text(message).font(.subheadline)
            HStack {
                if let s = secondary {
                    OutlinedButton(title: s.0, action: s.1)
                }
                PrimaryButton(title: primary.0, action: primary.1)
            }
        }
        .padding()
    }
}
