import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: UserSession

    @State private var serverURL: String = SharedStore.serverURL ?? "http://localhost:3002"
    @State private var email: String = SharedStore.userEmail ?? ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Image(systemName: "chart.bar.xaxis.ascending")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)
                Text("Sub2API Monitor")
                    .font(.title).bold()
                Text("Connect to your sub2api panel")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 12) {
                Text("Server URL")
                    .font(.caption).foregroundStyle(.secondary)
                TextField("http://your-host:3002", text: $serverURL)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()

                Text("Email")
                    .font(.caption).foregroundStyle(.secondary)
                TextField("you@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()

                Text("Password")
                    .font(.caption).foregroundStyle(.secondary)
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 8)

            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: submit) {
                HStack {
                    if isLoading {
                        ProgressView().controlSize(.small)
                    }
                    Text("Sign In")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading || serverURL.isEmpty || email.isEmpty || password.isEmpty)

            Spacer()
        }
        .padding(24)
    }

    private func submit() {
        errorText = nil
        isLoading = true

        // 规范化 URL：去掉尾部斜杠
        var normalized = serverURL.trimmingCharacters(in: .whitespaces)
        if normalized.hasSuffix("/") { normalized.removeLast() }
        SharedStore.serverURL = normalized

        Task {
            defer { isLoading = false }
            do {
                let user = try await AuthService.shared.login(email: email, password: password)
                session.markLoggedIn(user: user)
                await session.refreshNow()
            } catch {
                errorText = error.localizedDescription
            }
        }
    }
}
