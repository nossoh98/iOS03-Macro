//
//  APIProvider.swift
//
//
//  Created by 김나훈 on 11/16/23.
//

import Combine
import Foundation

/// API 요청을 하는 Provider 입니다.
public final class APIProvider: Requestable {
    public func mockRequest<Target, Model>(_ target: Target) -> AnyPublisher<Model, NetworkError> where Target : EndPoint, Model : Decodable {
        guard let request = try? target.mockRequest()
        else {
            return Fail(error: NetworkError.invalidURLRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                return data
            }
            .tryMap { data in
                guard let response = try? JSONDecoder().decode(Model.self, from: data) else {
                    throw NetworkError.decodingError
                }
                return response
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: Properties
    
    /// HTTP 요청을 수행하기 위한 Session
    private let session: Session
    
    // MARK: Initialization
    
    public init(session: Session) {
        self.session = session
    }
    
    // MARK: Method
    
    public func request<Target, Model>(_ target: Target) -> AnyPublisher<Model, NetworkError> where Target : EndPoint, Model: Decodable {
        guard let request = try? target.asURLRequest()
        else {
            return Fail(error: NetworkError.invalidURLRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.invalidHTTPResponse
                }
                
                switch response.statusCode {
                case 200..<300: return data
                case 400..<500: throw NetworkError.invalidRequest
                case 500..<600: throw NetworkError.invalidServer
                default: throw NetworkError.unknownError
                }
            }
            .tryMap { data in
                guard let response = try? JSONDecoder().decode(Model.self, from: data) else {
                    throw NetworkError.decodingError
                }
                return response
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.unknownError
                }
            }
            .eraseToAnyPublisher()
    }
}

extension EndPoint {
    func mockRequest() throws -> URLRequest {
        guard let url = Bundle.main.url(forResource: "MockJson", withExtension: "json") else {
            throw NetworkError.invalidURL(url: baseURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.dictionary
    
        return request
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL(url: baseURL)
        }
        
        var request = URLRequest(url: url.appending(path: path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.dictionary
        
        switch parameter {
        case .plain:
            break
        case let .query(data):
            let queryDictionary = data.dictionary
            var components = URLComponents(string: url.appending(path: path).absoluteString)
            components?.queryItems = queryDictionary.map { URLQueryItem(name: $0, value: "\($1)") }
            request.url = components?.url
        case let .body(data):
            let bodyDictionary = data.dictionary
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyDictionary)
        }
        
        return request
    }
}

private extension Encodable {
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any] else { return [:] }
        return dictionaryData
    }
}
