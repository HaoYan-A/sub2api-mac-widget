import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var session: UserSession
    @State private var serverURL: String = SharedStore.serverURL ?? ""

    var body: some View {
        Form {
            Section("Server") {
                TextField("Base URL", text: $serverURL)
                    .onSubmit { saveServerURL() }
                Button("Save") { saveServerURL() }
            }

            Section("Account") {
                LabeledContent("Email", value: session.email.isEmpty ? "-" : session.email)
                Button(role: .destructive) {
                    Task {
                        await AuthService.shared.logout()
                        session.markLoggedOut()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                } label: {
                    Text("Sign Out")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func saveServerURL() {
        var normalized = serverURL.trimmingCharacters(in: .whitespaces)
        if normalized.hasSuffix("/") { normalized.removeLast() }
        SharedStore.serverURL = normalized
    }
}
