import SwiftUI

struct NoteCard: View {
    let title: String
    let bodyText: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.notesText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(bodyText)
                .font(.system(size: 14))
                .foregroundColor(.notesGreyDark)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            // soft yellow card like the Figma
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.78)) // #FFF2C7 approx
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}

#Preview {
    NoteCard(title: "New Product\nIdea Design",
             bodyText: "Create a mobile app UI Kit that provide a basic notes functionality but with some improvement.") { }
    .padding()
    .background(Color.notesBackground)
}
