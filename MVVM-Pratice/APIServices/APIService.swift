//
//  APIService.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

class APIService {
//    https: //data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=f18de02f-b6c9-47c0-8cda-50efad621c14
    private let host: String
    private let basePath: String
    
    init(host: String = "data.taipei", basePath: String = "/opendata/datalist/apiAccess") {
        self.host = host
        self.basePath = basePath
    }
    
    enum Method: String, CustomStringConvertible {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        var description: String { return self.rawValue }
    }
    
    private struct Dummy: Codable {}
    
    func get<U: Decodable>(returnType: U.Type, path: String, query: [String: String]? = nil, token: String? = nil) -> Observable<Result<U,Error>> {
        return request(.get, U.self, path, query, Dummy?.none, token)
    }
    
    
    private func request<T: Encodable, U: Decodable>(_ method: Method,
                                                     _ returnType: U.Type,
                                                     _ path: String,
                                                     _ query: [String: String]?,
                                                     _ body: T?,
                                                     _ token: String?) -> Observable<Result<U,Error>> {
        let req = getURLRequest(method, path, query, body, token)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        return session.rx.response(request: req )
            .retry(3)
            .map { (response, data) -> Result<U,Error> in
                if response.statusCode == 403 {
                    return .failure(NSError(domain: "", code: 0, userInfo: nil))
                }
                if "" is U {
                    return .success((String(data: data, encoding: .utf8) ?? "") as! U)
                } else {
                    let decoder = JSONDecoder()
                    do {
                        let obj: U = try decoder.decode(U.self, from: data)
                        return .success(obj)
                    } catch (let err) {
                        print(err)
                        return .failure(NSError(domain: "", code: 0, userInfo: nil))
                    }
                }
            }
        
    }
    
    private func getURLRequest<T: Encodable>(_ method: Method, _ path: String, _ query: [String: String]?, _ body: T?, _ token: String?) -> URLRequest {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = basePath
        if let query = query {
            var queryItems: [URLQueryItem] = []
            for (key, value) in query {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
        }
        guard let url = components.url else { fatalError("URL is invalid") }
        print(url)
        
        // URLRequest
        var req = URLRequest(url: url)
        req.httpMethod = method.description
        
        // token
        if let token = token {
            req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // body
        if let body = body {
            req.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(body)
                req.httpBody = data
            } catch {
                fatalError("Request body is invalid")
            }
        }
        return req
    }
}
