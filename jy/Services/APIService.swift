import Foundation

// API 响应的基础模型
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T
}

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

class APIService {
    static let shared = APIService()
    private let networkService = NetworkService.shared
    
    // 用户认证令牌
    @UserDefault(key: "auth_token", defaultValue: nil)
    private var authToken: String?
    
    private init() {}
    
    // MARK: - 认证相关方法
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let parameters = LoginParameters(email: email, password: password)
        let response: APIResponse<AuthResponse> = try await networkService.request(
            endpoint: .login,
            method: .post,
            parameters: parameters
        )
        
        // 保存认证令牌
        self.authToken = response.data.token
        return response.data
    }
    
    func logout() {
        self.authToken = nil
    }
    
    // MARK: - 用户相关方法
    
    func getUserProfile(userId: String) async throws -> User {
        let response: APIResponse<User> = try await networkService.request(
            endpoint: .userProfile(id: userId),
            method: .get,
            headers: authHeaders
        )
        return response.data
    }
    
    func updateProfile(user: UpdateUserParameters) async throws -> User {
        let response: APIResponse<User> = try await networkService.request(
            endpoint: .updateProfile,
            method: .put,
            parameters: user,
            headers: authHeaders
        )
        return response.data
    }
    
    // MARK: - 通用方法
    
    func fetchPaginatedData<T: Codable>(
        endpoint: APIEndpoint,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> PaginatedResponse<T> {
        return try await networkService.getPaginatedData(
            endpoint: endpoint,
            page: page,
            pageSize: pageSize,
            additionalParams: nil
        )
    }
    
    // MARK: - 文件上传
    
    func uploadFile(
        data: Data,
        filename: String,
        mimeType: String,
        endpoint: APIEndpoint
    ) async throws -> UploadResponse {
        let response: APIResponse<UploadResponse> = try await networkService.upload(
            endpoint: endpoint,
            data: data,
            filename: filename,
            mimeType: mimeType
        )
        return response.data
    }
    
    // MARK: - 辅助方法
    
    private var authHeaders: [String: String] {
        guard let token = authToken else { return [:] }
        return ["Authorization": "Bearer \(token)"]
    }
}

// MARK: - 请求参数模型

struct LoginParameters: Codable {
    let email: String
    let password: String
}

struct UpdateUserParameters: Codable {
    let name: String?
    let email: String?
    let avatar: String?
}

// MARK: - 响应模型

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let avatar: String?
    let createdAt: Date
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct UploadResponse: Codable {
    let url: String
    let filename: String
} 