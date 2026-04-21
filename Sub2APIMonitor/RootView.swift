import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: UserSession

    var body: some View {
        Group {
            if session.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}
