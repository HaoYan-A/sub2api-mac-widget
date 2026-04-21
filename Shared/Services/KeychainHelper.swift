import Foundation
import Security

/// macOS Keychain 读写封装
/// 用于安全保存登录密码和 refresh_token
enum KeychainHelper {

    enum Key: String {
        case password
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
    }

    /// 保存字符串到 Keychain
    @discardableResult
    static func save(_ value: String, for key: Key, account: String = "default") -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConfig.keychainService,
            kSecAttrAccount as String: "\(key.rawValue)_\(account)"
        ]

        // 先删后加，避免重复
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let status = SecItemAdd(attributes as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// 读取
    static func read(_ key: Key, account: String = "default") -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConfig.keychainService,
            kSecAttrAccount as String: "\(key.rawValue)_\(account)",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }

    /// 删除
    @discardableResult
    static func delete(_ key: Key, account: String = "default") -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConfig.keychainService,
            kSecAttrAccount as String: "\(key.rawValue)_\(account)"
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// 清除所有凭据（退出登录用）
    static func clearAll() {
        [Key.password, .refreshToken, .accessToken].forEach { delete($0) }
    }
}
