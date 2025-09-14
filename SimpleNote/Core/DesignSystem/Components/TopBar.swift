import SwiftUI

struct TopBar: View {
    var title: String
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                }
            }
            Spacer()
            Text(title).font(.headline)
            Spacer()
            // placeholder for trailing
            Color.clear.frame(width: 24, height: 24)
        }
        .padding()
        .background(Color.notesSurface)
    }
}

#Preview {
    TopBar(title: "Title")
}
