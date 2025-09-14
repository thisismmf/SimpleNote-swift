import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var container: AppContainer

    var onChangePassword: () -> Void
    var onLogout: () -> Void

    @State private var user: UserInfoDTO?
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: "Settings", onBack: nil)

            if isLoading {
                ProgressView().padding(.top, 24)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // User header card (dynamic)
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.notesText)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(displayName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.notesText)

                                if let email = user?.email, !email.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "envelope")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(Color.notesGreyDark)
                                        Text(email)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.notesGreyDark)
                                    }
                                }

                                if let uname = user?.username, !uname.isEmpty {
                                    Text(uname)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.notesGreyBase)
                                }
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.notesGreyLight, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)

                        // Section divider + label
                        Divider().background(Color.notesGreyLight).padding(.horizontal, 16)

                        Text("APP SETTINGS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.notesGreyDark)
                            .padding(.horizontal, 16)

                        // Change password row
                        SettingsRow(
                            icon: "lock",
                            iconTint: .notesText,
                            title: "Change Password",
                            trailingChevron: true,
                            action: onChangePassword
                        )
                        .padding(.horizontal, 16)

                        Divider().background(Color.notesGreyLight).padding(.horizontal, 16)

                        // Logout row (red)
                        SettingsRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            iconTint: .notesError,
                            title: "Log Out",
                            titleTint: .notesError,
                            trailingChevron: false,
                            action: onLogout
                        )
                        .padding(.horizontal, 16)

                        if let e = errorText {
                            Text(e)
                                .font(.footnote)
                                .foregroundStyle(Color.notesError)
                                .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 24)
                        Text("Taha Notes v1.1")
                            .font(.caption2)
                            .foregroundStyle(Color.notesGreyLight)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 12)
                    }
                }
            }
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(false)
        .task { await loadUser() }
        .refreshable { await loadUser() }
    }

    private var displayName: String {
        let f = user?.first_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let l = user?.last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !(f.isEmpty && l.isEmpty) { return "\(f) \(l)".trimmingCharacters(in: .whitespaces) }
        return user?.username ?? "—"
    }

    private func loadUser() async {
        isLoading = true; errorText = nil
        defer { isLoading = false }
        do {
            user = try await container.authRepository.userInfo()
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Couldn’t load profile (\(code)): \(body)"
        } catch {
            errorText = error.localizedDescription
        }
    }
}

// Simple row component for Settings items
private struct SettingsRow: View {
    let icon: String
    var iconTint: Color = .notesText
    let title: String
    var titleTint: Color = .notesText
    var trailingChevron: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconTint)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(titleTint)
                Spacer()
                if trailingChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.notesGreyBase)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.notesGreyLight, lineWidth: 1)
            )
        }
    }
}
