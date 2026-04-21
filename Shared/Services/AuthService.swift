import Foundation

/// 登录 / Token 续期 / 高层 API 调用
/// 同时被主 App 和 Widget Extension 使用
actor AuthService {
    static let shared = AuthService()

    private let client = APIClient.shared
    private var inFlightRefresh: Task<String, Error>?

    // MARK: - 登录

    /// 首次登录：邮箱密码换取 Token
    /// 成功后把密码写入 Keychain，accessToken 和 refreshToken 同时入 Keychain
    func login(email: String, password: String) async throws -> UserInfo {
        let req = LoginRequest(email: email, password: password)
        let resp = try await client.post(
            path: "/api/v1/auth/login",
            body: req,
            responseType: LoginResponse.self
        )

        // 保存到 Keychain 和共享存储
        KeychainHelper.save(password, for: .password, account: email)
        KeychainHelper.save(resp.accessToken, for: .accessToken)
        KeychainHelper.save(resp.refreshToken, for: .refreshToken)
        SharedStore.userEmail = email

        return resp.user
    }

    /// 用 refresh_token 续期
    func refreshAccessToken() async throws -> String {
        if let existing = inFlightRefresh {
            return try await existing.value
        }
        let task = Task<String, Error> {
            defer { inFlightRefresh = nil }
            guard let refreshToken = KeychainHelper.read(.refreshToken) else {
                throw APIError.unauthorized
            }
            let req = RefreshRequest(refreshToken: refreshToken)
            let resp = try await client.post(
                path: "/api/v1/auth/refresh",
                body: req,
                responseType: LoginResponse.self
            )
            KeychainHelper.save(resp.accessToken, for: .accessToken)
            KeychainHelper.save(resp.refreshToken, for: .refreshToken)
            return resp.accessToken
        }
        inFlightRefresh = task
        return try await task.value
    }

    /// 密码重登（refresh 失败时的兜底）
    private func reloginWithStoredPassword() async throws -> String {
        guard let email = SharedStore.userEmail,
              let password = KeychainHelper.read(.password, account: email) else {
            throw APIError.unauthorized
        }
        _ = try await login(email: email, password: password)
        guard let token = KeychainHelper.read(.accessToken) else {
            throw APIError.unauthorized
        }
        return token
    }

    /// 退出登录
    func logout() {
        KeychainHelper.clearAll()
        SharedStore.userEmail = nil
        SharedStore.clearCache()
    }

    // MARK: - 带自动续期的请求

    /// 获取可用的 access token：优先读缓存，401 / JWT 即将过期则刷新
    func validAccessToken() async throws -> String {
        if let token = KeychainHelper.read(.accessToken),
           !isTokenExpiringSoon(token) {
            return token
        }
        // 先尝试 refresh
        do {
            return try await refreshAccessToken()
        } catch {
            // refresh 失败，兜底密码重登
            return try await reloginWithStoredPassword()
        }
    }

    /// 获取今日/累计统计，带自动续期
    func fetchDashboardStats() async throws -> DashboardStats {
        let token = try await validAccessToken()
        do {
            let stats = try await client.get(
                path: "/api/v1/usage/dashboard/stats",
                token: token,
                responseType: DashboardStats.self
            )
            SharedStore.lastStats = stats
            return stats
        } catch APIError.unauthorized {
            // 401：刷新 token 后重试一次
            let newToken = try await refreshAccessToken()
            let stats = try await client.get(
                path: "/api/v1/usage/dashboard/stats",
                token: newToken,
                responseType: DashboardStats.self
            )
            SharedStore.lastStats = stats
            return stats
        }
    }

    /// 获取近 7 天趋势（large widget 用）
    func fetchTrend() async throws -> [TrendPoint] {
        let token = try await validAccessToken()
        let resp = try await client.get(
            path: "/api/v1/usage/dashboard/trend",
            queryItems: [URLQueryItem(name: "granularity", value: "day")],
            token: token,
            responseType: TrendResponse.self
        )
        SharedStore.lastTrend = resp.trend
        return resp.trend
    }

    // MARK: - JWT 解析

    /// 解析 JWT payload 里的 exp 字段，判断是否即将过期
    private func isTokenExpiringSoon(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return true }

        var payload = String(parts[1])
        // Base64Url 补齐 padding
        let padLength = (4 - payload.count % 4) % 4
        payload += String(repeating: "=", count: padLength)
        payload = payload.replacingOccurrences(of: "-", with: "+")
                         .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }

        let now = Date().timeIntervalSince1970
        return (exp - now) < AppConfig.tokenRefreshThreshold
    }
}
