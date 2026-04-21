import Foundation

/// sub2api HTTP 客户端
/// 负责底层请求、统一响应解包、401 错误识别
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        config.waitsForConnectivity = false
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    /// 从 SharedStore 获取基础 URL
    private var baseURL: URL? {
        guard let urlString = SharedStore.serverURL,
              let url = URL(string: urlString) else {
            return nil
        }
        return url
    }

    // MARK: - 请求方法

    /// POST 请求（登录、refresh）
    func post<Req: Codable, Resp: Codable>(
        path: String,
        body: Req,
        token: String? = nil,
        responseType: Resp.Type
    ) async throws -> Resp {
        guard let base = baseURL else { throw APIError.notConfigured }
        let url = base.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(body)

        return try await perform(request: request, responseType: responseType)
    }

    /// GET 请求
    func get<Resp: Codable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        token: String,
        responseType: Resp.Type
    ) async throws -> Resp {
        guard let base = baseURL else { throw APIError.notConfigured }
        var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return try await perform(request: request, responseType: responseType)
    }

    // MARK: - 内部

    private func perform<T: Codable>(request: URLRequest, responseType: T.Type) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if http.statusCode == 401 {
            throw APIError.unauthorized
        }

        if !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.httpError(http.statusCode, body)
        }

        // sub2api 响应结构: {code, message, data}
        do {
            let wrapped = try decoder.decode(APIResponse<T>.self, from: data)
            if wrapped.code != 0 {
                throw APIError.businessError(wrapped.code, wrapped.message)
            }
            guard let inner = wrapped.data else {
                throw APIError.invalidResponse
            }
            return inner
        } catch let err as APIError {
            throw err
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
