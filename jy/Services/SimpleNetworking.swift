//
//  SimpleNetworking.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/20.
//
import Foundation
import MonkeyKing

/// 简单的网络请求工具类
class SimpleNetworking {
    
    /// 单例对象
    static let sharedInstance = SimpleNetworking()
    
    /// URLSession实例
    private let session = URLSession.shared

    /// 网络请求回调类型
    typealias NetworkingResponseHandler = ([String: Any]?, URLResponse?, Error?) -> Void

    /// HTTP请求方法枚举
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    /// 参数编码方式枚举
    enum ParameterEncoding {
        /// URL编码
        case url
        /// URL编码在URL中
        case urlEncodedInURL
        /// JSON编码
        case json

        /// 编码请求参数
        func encode(_ urlRequest: URLRequest, parameters: [String: Any]?) -> URLRequest {
            guard let parameters = parameters else {
                return urlRequest
            }
            var mutableURLRequest = urlRequest
            switch self {
            case .url, .urlEncodedInURL:
                // 将参数转换为查询字符串
                func query(_ parameters: [String: Any]) -> String {
                    var components: [(String, String)] = []
                    for key in parameters.keys.sorted(by: <) {
                        let value = parameters[key]!
                        components += queryComponents(key, value)
                    }
                    return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
                }
                
                // 判断是否需要在URL中编码参数
                func encodesParametersInURL(_ method: Method) -> Bool {
                    switch self {
                    case .urlEncodedInURL:
                        return true
                    default:
                        break
                    }
                    switch method {
                    case .get:
                        return true
                    default:
                        return false
                    }
                }
                
                if let method = Method(rawValue: mutableURLRequest.httpMethod!), encodesParametersInURL(method) {
                    if var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false) {
                        let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                        urlComponents.percentEncodedQuery = percentEncodedQuery
                        mutableURLRequest.url = urlComponents.url
                    }
                } else {
                    if mutableURLRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                        mutableURLRequest.setValue(
                            "application/x-www-form-urlencoded; charset=utf-8",
                            forHTTPHeaderField: "Content-Type"
                        )
                    }
                    mutableURLRequest.httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
                }
            case .json:
                do {
                    let options = JSONSerialization.WritingOptions()
                    let data = try JSONSerialization.data(withJSONObject: parameters, options: options)

                    mutableURLRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                    mutableURLRequest.setValue("application/json", forHTTPHeaderField: "X-Accept")
                    mutableURLRequest.httpBody = data
                } catch {
                    print(error)
                }
            }
            return mutableURLRequest
        }

        /// 生成查询参数组件
        func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
            var components: [(String, String)] = []
            if let dictionary = value as? [String: Any] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents("\(key)[\(nestedKey)]", value)
                }
            } else if let array = value as? [Any] {
                for value in array {
                    components += queryComponents("\(key)[]", value)
                }
            } else {
                components.append((escape(key), escape("\(value)")))
            }
            return components
        }

        /// URL编码字符串
        func escape(_ string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="
            let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
            allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
            var escaped = ""
            if #available(iOS 8.3, *) {
                escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
            } else {
                let batchSize = 50
                var index = string.startIndex
                while index != string.endIndex {
                    let startIndex = index
                    let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? startIndex
                    let substring = string[startIndex ..< endIndex]
                    escaped += (substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? String(substring))
                    index = endIndex
                }
            }
            return escaped
        }
    }

    /// 发送网络请求
    func request(_ urlString: String, method: Method, parameters: [String: Any]? = nil, encoding: ParameterEncoding = .url, headers: [String: String]? = nil, completionHandler: @escaping NetworkingResponseHandler) {
        guard let url = URL(string: urlString) else {
            return
        }
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        let request = encoding.encode(mutableURLRequest, parameters: parameters)
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]?
            defer {
                completionHandler(json, response, error)
            }
            guard
                let validData = data,
                let jsonData = try? JSONSerialization.jsonObject(with: validData, options: .allowFragments) as? [String: Any] else {
                print("sample networking requet failt: JSON could not be serialized because input data was nil.")
                return
            }
            json = jsonData
        }
        task.resume()
    }

    /// 上传文件
    func upload(_ urlString: String, parameters: [String: Any], completionHandler: @escaping NetworkingResponseHandler) {
        let tuple = urlRequestWithComponents(urlString, parameters: parameters)
        guard let request = tuple.request, let data = tuple.data else {
            return
        }
        let uploadTask = session.uploadTask(with: request, from: data) { data, response, error in
            var json: [String: Any]?
            defer {
                completionHandler(json, response, error)
            }
            guard
                let validData = data,
                let jsonData = try? JSONSerialization.jsonObject(with: validData, options: .allowFragments) as? [String: Any] else {
                print("sample networking upload failt: JSON could not be serialized because input data was nil.")
                return
            }
            json = jsonData
        }
        uploadTask.resume()
    }

    /// 生成上传请求组件
    private func urlRequestWithComponents(_ urlString: String, parameters: [String: Any], encoding: ParameterEncoding = .url) -> (request: URLRequest?, data: Data?) {
        guard let url = URL(string: urlString) else {
            return (nil, nil)
        }
        // create url request to send
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = Method.post.rawValue
        let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        let contentType = "multipart/form-data;boundary=" + boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")

        var uploadData = Data()
        // add parameters
        for (key, value) in parameters {
            guard let encodeBoundaryData = "\r\n--\(boundaryConstant)\r\n".data(using: .utf8) else {
                return (nil, nil)
            }
            uploadData.append(encodeBoundaryData)
            if let imageData = value as? Data {
                let filename = arc4random()
                let filenameClause = "filename=\"\(filename)\""
                let contentDispositionString = "Content-Disposition: form-data; name=\"\(key)\";\(filenameClause)\r\n"
                let contentDispositionData = contentDispositionString.data(using: .utf8)
                uploadData.append(contentDispositionData!)
                // append content type
                let contentTypeString = "Content-Type: image/JPEG\r\n\r\n"
                guard let contentTypeData = contentTypeString.data(using: .utf8) else {
                    return (nil, nil)
                }
                uploadData.append(contentTypeData)
                uploadData.append(imageData)
            } else {
                guard let encodeDispositionData = "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: .utf8) else {
                    return (nil, nil)
                }
                uploadData.append(encodeDispositionData)
            }
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: .utf8)!)
        return (encoding.encode(mutableURLRequest, parameters: nil), uploadData)
    }
}
