import SwiftUI

struct HomeScreen: View {
    var onOpenSettings: () -> Void
    var onOpenNote: (String) -> Void
    var onCreateNote: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Notes").font(.largeTitle).bold()
                Spacer()
                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape")
                }
            }.padding(.horizontal, 24)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { idx in
                        NoteCard(title: "Sample Note \(idx+1)", bodyText: "Tap to open")
                            .onTapGesture { onOpenNote("\(idx+1)") }
                            .padding(.horizontal, 24)
                    }
                }.padding(.top, 12)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: onCreateNote) {
                Image(systemName: "plus")
                    .font(.title2).padding()
                    .background(Circle().fill(Color.notesPrimary))
                    .foregroundColor(.white)
                    .shadow(radius: 3)
            }.padding(24)
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeScreen(onOpenSettings: {}, onOpenNote: { _ in }, onCreateNote: {})
}
