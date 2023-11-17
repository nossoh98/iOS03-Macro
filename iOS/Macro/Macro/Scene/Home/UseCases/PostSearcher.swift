//
//  PostSearcher.swift
//  Macro
//
//  Created by Byeon jinha on 11/17/23.
//

import Combine
import Foundation
import Network

protocol PostSearchUseCase {
    func searchPost() -> AnyPublisher<[PostResponse], NetworkError>
    func searchMockPost() -> AnyPublisher<[PostResponse], NetworkError>
}

final class PostSearcher: PostSearchUseCase {
    
    private let provider: Requestable
    
    init(provider: Requestable) {
        self.provider = provider
    }
    
    func searchPost() -> AnyPublisher<[PostResponse], Network.NetworkError> {
        return provider.request(PostEndPoint.search)
    }
    
    func searchMockPost() -> AnyPublisher<[PostResponse], Network.NetworkError> {
        return provider.mockRequest(PostEndPoint.search)
    }
}
