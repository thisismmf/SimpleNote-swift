import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var container: AppContainer
    var onOpenSettings: () -> Void
    var onOpenNote: (Int) -> Void
    var onCreateNote: () -> Void

    @State private var notes: [Note] = []
    @State private var isLoading = false
    @State private var errorText: String?
    @State private var query = ""

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.notesBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                // Top row: settings button on the right
                HStack {
                    Text("") // spacer to keep settings on the right
                    Spacer()
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.notesPrimary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search...", text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.notesGreyLight, lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Centered title
                Text("Notes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.notesText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                if isLoading {
                    ProgressView().padding(.top, 24)
                    Spacer()
                } else if let e = errorText {
                    Text(e).foregroundColor(.notesError)
                        .padding(.horizontal, 24)
                    Spacer()
                } else if filtered(notes).isEmpty {
                    Spacer()
                    Image(systemName: "figure.walk")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.notesPrimary)
                        .padding(.bottom, 8)
                    Text("Start Your Journey")
                        .font(.title2).bold()
                    Text("Every big step start with small step.\nNotes your first idea and start your journey!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.notesGreyDark)
                        .padding(.horizontal, 32)
                    Spacer(minLength: 80)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                            ForEach(filtered(notes), id: \.id) { n in
                                NoteCard(title: n.title, bodyText: n.description) {
                                    onOpenNote(n.id)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 100) // room for FAB
                    }
                }
            }
        }
        // Center FAB like Figma
        .overlay(alignment: .bottom) {
            Button(action: onCreateNote) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(22)
                    .background(Circle().fill(Color.notesPrimary))
                    .foregroundStyle(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
            }
            .padding(.bottom, 22)
        }
        .navigationBarBackButtonHidden(true)
        .task { await loadNotes() }
        .onAppear { Task { await loadNotes() } } // refresh when returning
    }

    private func filtered(_ list: [Note]) -> [Note] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return list }
        return list.filter { $0.title.lowercased().contains(q) || $0.description.lowercased().contains(q) }
    }

    private func loadNotes() async {
        isLoading = true; defer { isLoading = false }
        do {
            let page = try await container.notesRepository.list(page: 1, pageSize: 100)
            notes = page.items
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Load failed (\(code)): \(body)"
        } catch {
            errorText = error.localizedDescription
        }
    }
}
