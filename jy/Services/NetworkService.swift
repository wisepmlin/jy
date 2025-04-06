import Foundation

// HTTP 状态码枚举
enum HTTPStatusCode: Int {
    // 2xx: 成功
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    
    // 3xx: 重定向
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case temporaryRedirect = 307
    case permanentRedirect = 308
    
    // 4xx: 客户端错误
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case conflict = 409
    case tooManyRequests = 429
    
    // 5xx: 服务器错误
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    
    var isSuccess: Bool {
        return (200...299).contains(rawValue)
    }
    
    var description: String {
        switch self {
        case .ok: return "请求成功"
        case .created: return "创建成功"
        case .accepted: return "请求已接受"
        case .noContent: return "无内容"
        case .movedPermanently: return "永久移动"
        case .found: return "临时移动"
        case .seeOther: return "查看其他位置"
        case .temporaryRedirect: return "临时重定向"
        case .permanentRedirect: return "永久重定向"
        case .badRequest: return "请求参数错误"
        case .unauthorized: return "未授权"
        case .forbidden: return "禁止访问"
        case .notFound: return "资源不存在"
        case .methodNotAllowed: return "方法不允许"
        case .conflict: return "资源冲突"
        case .tooManyRequests: return "请求过于频繁"
        case .internalServerError: return "服务器内部错误"
        case .notImplemented: return "未实现"
        case .badGateway: return "网关错误"
        case .serviceUnavailable: return "服务不可用"
        case .gatewayTimeout: return "网关超时"
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(DecodingError)
    case serverError(HTTPStatusCode)  // 修改为使用 HTTPStatusCode
    case clientError(HTTPStatusCode)  // 新增客户端错误类型
    case redirectError(HTTPStatusCode) // 新增重定向错误类型
    case unknown(Error)
    case invalidParameters
    
    var description: String {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .serverError(let status):
            return "服务器错误(\(status.rawValue)): \(status.description)"
        case .clientError(let status):
            return "客户端错误(\(status.rawValue)): \(status.description)"
        case .redirectError(let status):
            return "重定向(\(status.rawValue)): \(status.description)"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        case .invalidParameters:
            return "无效的参数"
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeoutInterval
        self.session = URLSession(configuration: config)
    }
    
    // 核心请求方法
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let fullEndpoint = APIConfig.baseURL + endpoint.path
        
        guard var urlComponents = URLComponents(string: fullEndpoint) else {
            throw NetworkError.invalidURL
        }
        
        // 处理 GET 参数
        if method == .get, let parameters = parameters {
            let mirror = Mirror(reflecting: parameters)
            let queryItems = mirror.children.compactMap { child -> URLQueryItem? in
                guard let label = child.label else { return nil }
                return URLQueryItem(name: label, value: "\(child.value)")
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 设置默认请求头
        APIConfig.defaultHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // 添加自定义请求头
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // 处理请求体
        if method != .get, let parameters = parameters {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try? encoder.encode(parameters)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "", code: -1))
            }
            
            // 处理 HTTP 状态码
            if let statusCode = HTTPStatusCode(rawValue: httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 200...299:
                    // 成功状态，继续处理
                    break
                case 300...399:
                    throw NetworkError.redirectError(statusCode)
                case 400...499:
                    throw NetworkError.clientError(statusCode)
                case 500...599:
                    throw NetworkError.serverError(statusCode)
                default:
                    throw NetworkError.unknown(NSError(domain: "", code: httpResponse.statusCode))
                }
            }
            
            // 如果没有内容但状态码是成功的，返回空对象（如果支持的话）
            if httpResponse.statusCode == HTTPStatusCode.noContent.rawValue,
               let EmptyResponse = T.self as? EmptyResponse.Type {
                return EmptyResponse.init() as! T
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    // 便捷方法：获取分页数据
    func getPaginatedData<T: Codable>(
        endpoint: APIEndpoint,
        page: Int = 1,
        pageSize: Int = 20,
        additionalParams: Encodable? = nil
    ) async throws -> PaginatedResponse<T> {
        let params = PaginationParams(page: page, pageSize: pageSize)
        return try await request(endpoint: endpoint, method: .get, parameters: params)
    }
    
    // 便捷方法：上传数据
    func upload<T: Decodable>(
        endpoint: APIEndpoint,
        data: Data,
        filename: String,
        mimeType: String
    ) async throws -> T {
        let fullEndpoint = APIConfig.baseURL + endpoint.path
        guard let url = URL(string: fullEndpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (responseData, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "", code: -1))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(HTTPStatusCode(rawValue: httpResponse.statusCode)!)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: responseData)
    }
}

// 用于处理无内容响应的协议
protocol EmptyResponse {
    init()
} 
