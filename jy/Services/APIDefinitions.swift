import Foundation

// HTTP 方法枚举
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// API 端点枚举
enum APIEndpoint {
    // 用户相关
    case login
    case register
    case userProfile(id: String)
    case updateProfile
    
    // 其他端点根据需求添加...
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .userProfile(let id):
            return "/users/\(id)"
        case .updateProfile:
            return "/users/profile"
        }
    }
}

// 通用的分页参数
struct PaginationParams: Encodable {
    let page: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case pageSize = "page_size"
    }
}

// 通用的分页响应
struct PaginatedResponse<T: Codable>: Codable {
    let total: Int
    let pages: Int
    let currentPage: Int
    let items: [T]
}

// API 配置
struct APIConfig {
    static let baseURL = "https://api.example.com"  // 替换为实际的API地址
    static let defaultHeaders: [String: String] = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    static let timeoutInterval: TimeInterval = 30
} 