import Foundation

/// sub2api 通用响应包装
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}

/// 接口错误
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, String)
    case businessError(Int, String)
    case decodingError(Error)
    case unauthorized
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid server URL"
        case .invalidResponse: return "Invalid response from server"
        case .httpError(let code, let msg): return "HTTP \(code): \(msg)"
        case .businessError(let code, let msg): return "API error \(code): \(msg)"
        case .decodingError(let err): return "Decoding failed: \(err.localizedDescription)"
        case .unauthorized: return "Please login again"
        case .notConfigured: return "Server not configured"
        }
    }
}
