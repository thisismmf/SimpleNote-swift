import SwiftUI

struct SettingsScreen: View {
    var onChangePassword: () -> Void
    var onLogout: () -> Void

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "person.crop.circle.fill").font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text("Taha Hamifar").font(.headline)
                        Text("hamifar.taha@gmail.com").foregroundColor(.notesGreyDark)
                        // or, if you want to be explicit:
                        Text(verbatim: "hamifar.taha@gmail.com").foregroundColor(.notesGreyDark)
                    }
                }
            }
            Section {
                Button("Change Password", action: onChangePassword)
                Button(role: .destructive, action: onLogout) {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsScreen(onChangePassword: {}, onLogout: {})
}
