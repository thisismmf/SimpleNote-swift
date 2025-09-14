import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var container: AppContainer
    var onOpenSettings: () -> Void
    var onOpenNote: (Int) -> Void
    var onCreateNote: () -> Void

    // Data
    @State private var notes: [Note] = []

    // Paging
    @State private var currentPage: Int = 1
    @State private var pageSize: Int = 20
    @State private var totalCount: Int = 0
    @State private var isLoadingFirst = false
    @State private var isLoadingMore = false
    @State private var hasMore = false

    // Search
    @State private var query: String = ""
    @State private var searchTask: Task<Void, Never>?

    // Errors
    @State private var errorText: String?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.notesBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Text("")  // keeps settings to the right
                    Spacer()
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.notesPrimary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                // Search bar (debounced)
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search...", text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onSubmit { Task { await reloadFromFirstPage() } }
                        .onChange(of: query) { _ in
                            searchTask?.cancel()
                            searchTask = Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
                                await reloadFromFirstPage()
                            }
                        }
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

                Text("Notes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.notesText)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                if isLoadingFirst {
                    ProgressView().padding(.top, 24)
                    Spacer()
                } else if let e = errorText {
                    Text(e).foregroundColor(.notesError)
                        .padding(.horizontal, 24)
                    Spacer()
                } else if notes.isEmpty {
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
                            ForEach(Array(notes.enumerated()), id: \.element.id) { index, n in
                                NoteCard(title: n.title, bodyText: n.description) {
                                    onOpenNote(n.id)
                                }
                                // Infinite scroll trigger when last item appears
                                .onAppear {
                                    if index == notes.indices.last && hasMore && !isLoadingMore {
                                        Task { await loadNextPage() }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 100) // room for FAB

                        if isLoadingMore {
                            ProgressView().padding(.bottom, 24)
                        } else if hasMore {
                            // fallback button if the appear trigger misses
                            Button("Load more") { Task { await loadNextPage() } }
                                .padding(.bottom, 24)
                        }
                    }
                    .refreshable { await reloadFromFirstPage() }
                }
            }
        }
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
        .task { await reloadFromFirstPage() } // initial load
        .onAppear { /* returning from detail/edit → keep list; no auto reload here */ }
    }

    // MARK: - Paging

    @MainActor
    private func reloadFromFirstPage() async {
        isLoadingFirst = true
        isLoadingMore = false
        errorText = nil
        hasMore = false
        currentPage = 1
        notes.removeAll()

        await loadPage(page: currentPage, append: false)
    }

    private func loadNextPage() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        await loadPage(page: currentPage, append: true)
    }

    private func loadPage(page: Int, append: Bool) async {
        do {
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let pageData: (items: [Note], count: Int, next: String?, previous: String?)

            if trimmed.isEmpty {
                pageData = try await container.notesRepository.list(page: page, pageSize: pageSize)
            } else {
                // search hits title OR description on server
                pageData = try await container.notesRepository.filter(
                    title: trimmed, description: trimmed,
                    page: page, pageSize: pageSize,
                    updatedGte: nil, updatedLte: nil
                )
            }

            if append {
                notes.append(contentsOf: pageData.items)
            } else {
                notes = pageData.items
            }

            totalCount = pageData.count
            // DRF 'count' is total across all pages; if unknown (0 with results), fallback to length check
            let totalKnown = totalCount > 0 ? totalCount : notes.count + (pageData.next != nil ? pageSize : 0)
            hasMore = notes.count < totalKnown || pageData.next != nil

            // next logical page (server is 1-based)
            currentPage += 1
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Load failed (\(code)): \(body)"
        } catch {
            errorText = error.localizedDescription
        }
        isLoadingFirst = false
    }
}
