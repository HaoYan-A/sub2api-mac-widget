import SwiftUI
import WidgetKit

@main
struct Sub2APIMonitorApp: App {
    @StateObject private var session = UserSession()

    var body: some Scene {
        WindowGroup("Sub2API Monitor") {
            RootView()
                .environmentObject(session)
                .frame(minWidth: 480, minHeight: 360)
        }
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(session)
                .frame(width: 420, height: 280)
        }
    }
}

/// 全局会话状态
@MainActor
final class UserSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var email: String = ""
    @Published var user: UserInfo?
    @Published var latestStats: DashboardStats?
    @Published var lastUpdatedAt: Date?
    @Published var errorMessage: String?

    init() {
        // 判断初始登录状态：有邮箱、有 access_token、有 serverURL
        let hasServerURL = (SharedStore.serverURL?.isEmpty == false)
        let hasEmail = (SharedStore.userEmail?.isEmpty == false)
        let hasToken = (KeychainHelper.read(.accessToken) != nil)
        self.isLoggedIn = hasServerURL && hasEmail && hasToken
        self.email = SharedStore.userEmail ?? ""
        self.latestStats = SharedStore.lastStats
        self.lastUpdatedAt = SharedStore.lastStatsAt
    }

    func markLoggedIn(user: UserInfo) {
        self.user = user
        self.email = user.email
        self.isLoggedIn = true
        self.errorMessage = nil
    }

    func markLoggedOut() {
        self.isLoggedIn = false
        self.user = nil
        self.latestStats = nil
    }

    func refreshNow() async {
        do {
            let stats = try await AuthService.shared.fetchDashboardStats()
            self.latestStats = stats
            self.lastUpdatedAt = Date()
            self.errorMessage = nil
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
